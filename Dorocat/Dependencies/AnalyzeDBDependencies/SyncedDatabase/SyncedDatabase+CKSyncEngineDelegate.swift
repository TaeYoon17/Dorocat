//
//  SyncedDatabase+CKSyncEngineDelegate.swift
//  Dorocat
//
//  Created by Greem on 4/30/25.
//

import Foundation
import CloudKit
import os.log

extension SyncedDatabase : CKSyncEngineDelegate {
    
    /// CKSyncEngine에서 이벤트가 발생한 것을 알려준다.
    /// CKSyncEngine.Event는 CloudKit에서 동기화 엔진(CKSyncEngine)이 동작 중에 발생하는 이벤트를 나타내는 열거형(enum)
    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        Logger.database.debug("Handling event \(event)")
        /// State는 그 엔진이 현재까지 동기화를 어디까지 했는지, 어떤 레코드들을 처리했는지 등을 기억하는 객체
        /// Serialization은 직렬화하여 CoreData나 로컬에 저장할 수 있게 만듦
        switch event {
        case .stateUpdate(let event): // 상태 업데이트, 저장 공간에 최신 상태가 무엇인지 저장하게 만들 필요가 있다.
            self.stateSerialization = event.stateSerialization
        case .accountChange(let event): // 계정이 바뀜
            self.handleAccountChange(event)
        case .fetchedDatabaseChanges(let event): // 처리할 데이터베이스 변경 사항을 가져왔음. -> 레코드 존의 변경 사항을 알 것이다.
            await self.handleFetchedDatabaseChanges(event)
        case .fetchedRecordZoneChanges(let event): // 레코드 존 내부의 테이블 변화를 가져온다. -> 튜플(레코드)의 추가나 삭제를 알 것이다.
            await self.handleFetchedRecordZoneChanges(event)
        case .sentRecordZoneChanges(let event):
            await self.handleSentRecordZoneChanges(event)
        case .sentDatabaseChanges: break
        case .willSendChanges, .willFetchChanges: // 여기에 동기화 시작 토글링
            Logger.database.debug("값이 바뀐 것을 감지하기 시작!!")
            for syncHandler in self.syncHandlers.values {
                await syncHandler?.synchronizeStart()
            }
        case .didFetchChanges, .didSendChanges: // 여기에 동기화 끝남 토글링
            Logger.database.debug("값이 바뀐 것 끝남!!")
        // We don't do anything here in the sample app, but these events might be helpful if you need to do any setup/cleanup when sync starts/ends.
            for syncHandler in self.syncHandlers.values {
                await syncHandler?.synchronizeEnd()
            }
        case .willFetchRecordZoneChanges, .didFetchRecordZoneChanges: break
        @unknown default:
            Logger.database.info("Received unknown event: \(event)")
        }
    }
    
    
    
    
    /// 보낸 레코드(튜플)의 변화를 조작한다.
    func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) async {
        // 만약 레코드의 저장을 실패했다면, 에라 코드를 추적해 새로 요청하게 만들어야한다.
        var newPendingRecordZoneChanges: [CKSyncEngine.PendingRecordZoneChange] = []
        var newPendingDatabaseChanges: [CKSyncEngine.PendingDatabaseChange] = []
        
        /// 서버의 값이 최신이라 로컬 값을 업데이트 해야 하는 대상들
        var overWriteTargets:[CKRecord.RecordEntityType: Set<CKRecord>] = [:]
        var removeTargets: [CKRecord.RecordEntityType: [CKRecord]] = [:]
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
            guard let localNewerItems = await syncHandlers[entityType]??.overWriteEntities(type: entityType, records: Array(records)) else {
                continue
            }
            // 엔진에서 직접 변경을 요청한다
            guard let values = try? await self.syncEngine.database.modifyRecords(saving: localNewerItems, deleting: [], savePolicy: .allKeys) else {
                continue
            }
            // 즉시 서버 데이터 업데이트에 성공하면 다시 동기화할 레코드에 등록하지 않는다.
            let successedModifyCloudRecords = values.saveResults.filter { $0.value.is(\.success) }
            let removePendingRecordZoneChanges: [CKSyncEngine.PendingRecordZoneChange] = successedModifyCloudRecords.map { .saveRecord($0.key) }
            self.syncEngine.state.remove(pendingRecordZoneChanges: removePendingRecordZoneChanges)
        }
    }
    
    /// 로그인 시, 가장 최신에 로그인 한 아이클라우드 계정에 대한 정보를 담아놓는다.
    /// 기존 계정으로 재로그인 시: 현재 로컬에 있는 데이터와 동기화한다.
    /// 다른 계정으로 로그인 시: 완전히 새로운 계정의 데이터로 바꾼다.
    ///     추후에 사용자가 기존 작업을 버릴지 말지 선택하게 한다.
    /// 추가 대응방법: 기간 및 작업 별 백업을 만들어 동기화 할 수 있게 만든다.
    
    func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) {
        
        // 로그아웃 시 해당 기존 데이터들은 내비려 둔다.
        // 계정을 바꾸거나 새로 로그인 시, 기존 로컬 데이터에 값이 있다면 이들을 덮어 씌울 것인지 모두 삭제하고 연동작업을 진행할 것인지 물어본다.
        switch event.changeType {
        case .signIn, .switchAccounts:
            /// 여기 연동 작업을 요청하는 delegate 넘기기
            break
        case .signOut: break
        @unknown default: break
        }
    }
}

extension SyncedDatabase {
    /// 레코드존(테이블)이 변화함 => 레코드(튜플)들의 값을 수정함
    func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) async {
        
        /// 수정사항 -> 각각의 job들이 알아서 하위 변경 작업을 처리하게 한다.
        var modifications: [CKRecord.RecordEntityType: [CKRecord] ] = [:]
        var deletions: [CKRecord.RecordEntityType : [CKRecord.ID]] = [:]
        
//        var modificationItems:[TimerRecordItem] = []
        for modification in event.modifications {
            // 동기화 엔진이 레코드를 가져왔고, 이를 로컬 저장소에 병합하려고 합니다.
            // 이미 이 객체가 로컬에 존재한다면, 서버에서 가져온 데이터와 병합합니다.
            // 그렇지 않다면, 새로운 로컬 객체를 생성합니다.
            
            let record: CKRecord = modification.record
            let type = record.convertIDToRecordType
            
            if modifications[type] == nil {
                modifications[type] = [record]
            } else {
                modifications[type]?.append(record)
            }
        }
        
        for deletion in event.deletions {
            guard let type = CKRecord.RecordEntityType(rawValue: deletion.recordType) else {
                continue
            }
            
            if deletions[type] == nil {
                deletions[type] = [deletion.recordID]
            } else {
                deletions[type]?.append(deletion.recordID)
            }
        }
        
        for (key, val) in syncHandlers {
            guard let val else { continue }
            let modificationValues: [CKRecord] = modifications[key] ?? []
            let deletionValues = deletions[key] ?? []
            await val.handleFetchedRecordZoneChanges(
                type: key,
                modifications: modificationValues,
                deletions: deletionValues
            )
        }
    }
}


extension SyncedDatabase {
    /// 데이터 베이스 자체가 변화함 => 존 (테이블이 영향받음)
    func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) async {
        var zoneNames: Set<String> = .init()
        for deletion in event.deletions {
            zoneNames.insert(deletion.zoneID.zoneName)
        }
        
        for (_, val) in syncHandlers {
            await val?.handleFetchedDatabaseChanges(deletionZoneName: zoneNames)
        }
    }
}
