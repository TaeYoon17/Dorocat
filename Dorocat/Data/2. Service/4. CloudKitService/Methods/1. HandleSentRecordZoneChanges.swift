//
//  1. HandleSentRecordZoneChanges.swift
//  Dorocat
//
//  Created by Greem on 5/14/25.
//

import Foundation
import CloudKit
import os.log

extension CloudKitService {
    /// 보낸 레코드(튜플)의 변화를 조작한다.
    func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) async {
        // 만약 레코드의 저장을 실패했다면, 에라 코드를 추적해 새로 요청하게 만들어야한다.
        var newPendingRecordZoneChanges: [CKSyncEngine.PendingRecordZoneChange] = []
        var newPendingDatabaseChanges: [CKSyncEngine.PendingDatabaseChange] = []
        
        /// 서버의 값이 최신이라 로컬 값을 업데이트 해야 하는 대상들
        var overWriteTargets:[CKConstants.Label: Set<CKRecord>] = [:]
        var removeTargets: [CKConstants.Label: [CKRecord]] = [:]
        /// 실패한 레코드들을 다룬다.
        for failedRecordSave in event.failedRecordSaves {
            let failedRecord = failedRecordSave.record
            switch failedRecordSave.error.code {
            // 이 오류는 클라이언트가 저장하려는 로컬 레코드 버전보다 서버의 레코드 버전이 최신임을 나타냄
            case .serverRecordChanged:
                // 서버의 레코드를 우리 자신의 로컬 복사본에 병합하겠습니다.
                // `mergeFromServerRecord` 함수가 충돌 해결을 처리합니다.
                guard let serverRecord:CKRecord = failedRecordSave.error.serverRecord else {
                    print("서버 데이터를 찾을 수 없음!!")
                    continue
                }
                let type = serverRecord.convertIDToRecordType
                if overWriteTargets[type] == nil {
                    overWriteTargets[type] = [serverRecord]
                } else {
                    overWriteTargets[type]?.insert(serverRecord)
                }
                newPendingRecordZoneChanges.append(.saveRecord(serverRecord.recordID))
                
            case .zoneNotFound:
                // 존재하지 않는 영역에 레코드를 저장하려고 시도한 것 같습니다.
                // 해당 영역을 저장하고 레코드 저장을 다시 시도해 보겠습니다.
                // 또한, 이전에 알고 있던 서버 레코드가 있다면 더 이상 유효하지 않으므로 삭제합니다.
                // 이 Zone을 새로 만든다. + 이 존에 넣으려는 Record들을 다시 추가한다.
                // 일단은 로컬에 저장된 데이터는 지운다...
                guard let serverRecord:CKRecord = failedRecordSave.error.serverRecord else {
                    Logger.database.error("No server record for conflict \(failedRecordSave.error)")
                    continue
                }
                
                let type = serverRecord.convertIDToRecordType
                removeTargets[type]?.append(serverRecord)
                
                let zone = CKRecordZone(zoneID: failedRecord.recordID.zoneID)
                newPendingDatabaseChanges.append(.saveZone(zone))
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                
            case .unknownItem:
                // 로컬에 캐시된 서버 레코드를 사용하여 레코드를 저장하려고 시도했지만, 해당 레코드는 더 이상 서버에 존재하지 않습니다.
                // 이는 다른 기기가 레코드를 삭제했지만, 우리는 여전히 해당 레코드의 데이터를 로컬에 가지고 있다는 의미일 수 있습니다.
                // 우리는 로컬 데이터를 삭제하거나 로컬 데이터를 다시 업로드하는 두 가지 선택 사항이 있습니다.
                // 이 샘플 앱에서는 로컬 데이터를 다시 업로드하도록 하겠습니다.
                // 일단은 기존에 있던 데이터는 지운다...
                guard let serverRecord:CKRecord = failedRecordSave.error.serverRecord else {
                    Logger.database.error("No server record for conflict \(failedRecordSave.error)")
                    continue
                }
                
                let type = serverRecord.convertIDToRecordType
                removeTargets[type]?.append(serverRecord)
                newPendingRecordZoneChanges.append(.saveRecord(serverRecord.recordID))
                
            case .networkFailure, .networkUnavailable, .zoneBusy, .serviceUnavailable, .notAuthenticated, .operationCancelled:
                // There are several errors that the sync engine will automatically retry, let's just log and move on.
                Logger.database.debug("Retryable error saving \(failedRecord.recordID): \(failedRecordSave.error)")
                print("알 수 없는 오류")
            default: break
            }
        }
        
        // 일단 동기화 대상으로 추가함
        self.syncEngine.state.add(pendingDatabaseChanges: newPendingDatabaseChanges)
        self.syncEngine.state.add(pendingRecordZoneChanges: newPendingRecordZoneChanges)
        
        // 각각의 정보 타입에 맞게 순회한다.
        for (entityType, records) in overWriteTargets {
            // 로컬 데이터가 더 최신인 경우를 가져온다.
            guard let handler = syncHandlers[entityType], let handler else {
                continue
            }
            let localNewerRecords = await getFailedRecordsToRetry(label: entityType, handler: handler, records: records)
            // 엔진에서 직접 변경을 요청한다
            guard let values = try? await self.syncEngine.database.modifyRecords(
                saving: localNewerRecords,
                deleting: [],
                savePolicy: .allKeys
            ) else {
                continue
            }
            // 즉시 서버 데이터 업데이트에 성공하면 다시 동기화할 레코드에 등록하지 않는다.
            let successedModifyCloudRecords = values.saveResults.filter { $0.value.is(\.success) }
            let removePendingRecordZoneChanges: [CKSyncEngine.PendingRecordZoneChange] = successedModifyCloudRecords.map { .saveRecord($0.key) }
            self.syncEngine.state.remove(pendingRecordZoneChanges: removePendingRecordZoneChanges)
        }
    }
    
    
    private func getFailedRecordsToRetry<Handler: CloudKitServicingHandler>(label: CKConstants.Label, handler: Handler, records: Set<CKRecord>) async -> [CKRecord] {
        switch label {
        case .timerItem:
            guard let dtos = records.map({ CKTimerRecordDTO(record: $0)}) as? [Handler.CKDTO] else {
                assertionFailure("올바르지 않은 타입 변환")
                return []
            }
            
            var failedDTOs = Set<Handler.CKDTO>()
            var failedRecords: [CKRecord] = []
            await handler.applyRemoteToLocal(dtos: dtos, updateDTOs: &failedDTOs)
            for record in records {
                guard let recordID = CKTimerRecordDTO.ID(uuidString: record.recordID.recordName) as? Handler.CKDTO.ID else {
                    assertionFailure("타입이 맞지 않음!!")
                    continue
                }
                if let failedDTO = failedDTOs.first(where: { $0.id == recordID }) {
                    failedDTO.populateRecord(record)
                    failedRecords.append(record)
                }
            }
        case .session:
            assertionFailure("지정되지 않은 라벨")
        }
        return []
    }
    
}
