//
//  2. HandleFetchedRecordZoneChanges.swift
//  Dorocat
//
//  Created by Greem on 5/14/25.
//

import Foundation
import CloudKit
import os.log

extension CloudKitService {
    /// 레코드존(테이블)이 변화함 => 레코드(튜플)들의 값을 수정함
    func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) async {
        
        /// 수정사항 -> 각각의 job들이 알아서 하위 변경 작업을 처리하게 한다.
        var modifications: [CKConstants.Label: [CKRecord]] = [:]
        var deletions: [CKConstants.Label: [CKRecord.ID]] = [:]
        
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
            guard let type = CKConstants.Label(rawValue: deletion.recordType) else {
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
            let modificationRecords: [CKRecord] = modifications[key] ?? []
            let deletionRecordIDs: [CKRecord.ID] = deletions[key] ?? []
            await applyFetchedRecordChangesToHandler(
                label: key,
                handler: val,
                modifications: modificationRecords,
                deletions: deletionRecordIDs
            )
        }
    }
    
    private func applyFetchedRecordChangesToHandler<Handler: CloudKitServicingHandler>(
        label: CKConstants.Label,
        handler: Handler,
        modifications: [CKRecord],
        deletions: [CKRecord.ID]
    ) async {
        switch label {
        case .timerItem:
            guard let modificationDTOs = (modifications.map {
                CKTimerRecordDTO(record: $0)
            }) as? [Handler.CKDTO],
                  let deletionDTOIDs = (deletions.compactMap {
                      CKTimerRecordDTO.ID(uuidString: $0.recordName)
                  }) as? [Handler.CKDTO.ID]
            else {
                assertionFailure("[SyncedDatabase] 주어진 라벨과 타입 불일치 발생")
                return
            }
            await handler.applyFetchedRemoteValueChanges(
                modifications: modificationDTOs,
                deletions: deletionDTOIDs
            )
        case .session:
            assertionFailure("[SyncedDatabase] 정해지지 않은 라벨에 접근")
        }
    }
}
