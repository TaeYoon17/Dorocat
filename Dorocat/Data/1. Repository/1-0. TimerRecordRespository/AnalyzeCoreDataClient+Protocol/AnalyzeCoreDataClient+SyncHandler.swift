//
//  AnalyzeCoreDataClient+SyncHandler.swift
//  Dorocat
//
//  Created by Greem on 4/30/25.
//

import Foundation
import CloudKit

// MARK: - CKSyncEngineDelegate

extension AnalyzeCoreDataClient: SyncHandler {
    
    func synchronizeStart() async {
        self.syncrhozieEventContiuation?.yield(.start)
        Task.detached {
            try await Task.sleep(for: .seconds(10))
            await self.syncrhozieEventContiuation?.yield(.end)
        }
    }
    
    func synchronizeEnd() async {
        self.lastSyncedDate = Date()
        self.syncrhozieEventContiuation?.yield(.end)
    }
    

    func overWriteEntities(type: CKRecord.RecordEntityType, records: [CKRecord]) async -> [CKRecord] {
        var failedRecords: [CKRecord] = []
        for record in records {
            let id = UUID(uuidString: record.recordID.recordName)!
            guard var timerRecordItem = await findItemByID(id) else {
                continue
            }
            let serverIsNewer = timerRecordItem.mergeFromServerRecord(record)
            if serverIsNewer {
                await timerItemUpsert(item: timerRecordItem)
            } else {
                timerRecordItem.populateRecord(record)
                failedRecords.append(record)
            }
        }
        return failedRecords
    }
    
    
    func requestCKWritableForPendingRecord(id: String) async -> CKWritable? {
        guard let uuid = UUID(uuidString: id) else {
            assertionFailure("이게 이상해요...")
            return nil
        }
        let writable = await self.findItemByID(uuid)
        
        return writable
    }
    
    // 실제로 서버에서 받은 값들... 여기에 맞게 변경해줘야한다.
    func handleFetchedRecordZoneChanges(type: CKRecord.RecordEntityType, modifications: [CKRecord], deletions: [CKRecord.ID]) async {
        var modificationItems:[TimerRecordItem] = []
        var deletionItems: [TimerRecordItem] = []
            
        for modification in modifications {
            let record:CKRecord = modification
            guard record.convertIDToRecordType == .timerItem else { continue }
            let id = record.recordID.recordName
            let uuid = UUID(uuidString: id)!
            if var findItem = await findItemByID(uuid) {
                let isMerged = findItem.mergeFromServerRecord(record)
                if isMerged { modificationItems.append(findItem) }
            } else {
                let item = TimerRecordItem(record: record)
                modificationItems.append(item)
            }
            
        }
        let deletionIDs: [UUID] = deletions.map { UUID(uuidString: $0.recordName)! }
        for deletionId in deletionIDs {
            if let findItem = await findItemByID(deletionId) {
                deletionItems.append(findItem)
            }
        }
        for modificationItem in modificationItems {
            await timerItemUpsert(item: modificationItem)
        }
        try? await timerItemDeletes(items: deletionItems)
        analyzeEventContinuation?.yield(.fetch)
    }
    
    /// 데이터 베이스 자체가 변화함 => 존 (테이블이 영향받음)
    func handleFetchedDatabaseChanges(deletionZoneName: Set<String>) async {
        if deletionZoneName.contains(TimerRecordItem.zoneName) {
            try? await timerRecordDeleteAll()
        }
    }
    
    func handleAccountStatusChange(_ status: UserAccountStatusDTO) async {
        switch status {
        case .signIn: break
        case .signOut: /// 자동 동기화 및 일반 동기화 모두 가능하지 않게 한다.
            self.isAutomaticallySyncEnabled = false
            self.isICloudSyncEnabled = false
        }
    }
}
