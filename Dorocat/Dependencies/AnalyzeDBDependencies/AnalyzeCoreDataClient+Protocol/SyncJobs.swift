//
//  SyncJobs.swift
//  Dorocat
//
//  Created by Greem on 4/14/25.
//

import Foundation
import CloudKit
import CoreData

protocol SyncJobs {
    func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) async
    func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) async
    func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) async
    func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) async
    
    /// Pending 상태이던 레코드의 실제 값을 쓰기 위해 CKWritable 값을 요청한다.
    func requestCKWritableForPendingRecord(id: String) async -> CKWritable?
}

// MARK: - CKSyncEngineDelegate

extension AnalyzeCoreDataClient : SyncJobs {
    
    func requestCKWritableForPendingRecord(id: String) async -> CKWritable? {
        guard let uuid = UUID(uuidString: id) else {
            assertionFailure("이게 이상해요...")
            return nil
        }
        return await self.findItemByID(uuid)
    }
    
    // MARK: - CKSyncEngine Events
    
    /// 레코드존(테이블)이 변화함 => 레코드(튜플)들의 값을 수정함
    func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) async {
        /// 수정사항
        var modificationItems:[TimerRecordItem] = []
        for modification in event.modifications {
            // 동기화 엔진이 레코드를 가져왔고, 이를 로컬 저장소에 병합하려고 합니다.
            // 이미 이 객체가 로컬에 존재한다면, 서버에서 가져온 데이터와 병합합니다.
            // 그렇지 않다면, 새로운 로컬 객체를 생성합니다.
            let record:CKRecord = modification.record
            let id = record.recordID.recordName
            
            let uuid = UUID(uuidString: id)!
            let findItem = await findItemByID(uuid)
            if findItem == nil && record.convertIDToRecordType == .timerItem{
                var item = TimerRecordItem(record: record)
                modificationItems.append(item)
            }
        }
        
        let deletionIDs: [UUID] = event.deletions.map { UUID(uuidString: $0.recordID.recordName)! }
        var deletionItems: [TimerRecordItem] = []
        for deletionId in deletionIDs {
            if let findItem = await findItemByID(deletionId) {
                deletionItems.append(findItem)
            }
        }
        
        for modificationItem in modificationItems {
            await coredataAppend(item: modificationItem)
        }
        try? await coredataDelete(items: deletionItems)
        print("[\(#function)]변화를 감지했다..!")
        analyzeEventContinuation?.yield(.fetch)
    }
    
    /// 데이터 베이스 자체가 변화함 => 존 (테이블이 영향받음)
    func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) async {
        for deletion in event.deletions {
            switch deletion.zoneID.zoneName {
            case TimerRecordItem.zoneName:
                /// 모든 데이터를 지운다.
                try? await self.coredataDelete(items: [])
            default: continue
            }
        }
        
    }
    
    /// 보낸 레코드(튜플)의 변화를 조작한다.
    func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) async {
        
        // If we failed to save a record, we might want to retry depending on the error code.
        // 만약 레코드의 저장을 실패했다면, 에라 코드를 추적해 새로 요청하게 만들어야한다.
        var newPendingRecordZoneChanges = [CKSyncEngine.PendingRecordZoneChange]()
        var newPendingDatabaseChanges = [CKSyncEngine.PendingDatabaseChange]()
        
        // Handle any failed record saves.
        for failedRecordSave in event.failedRecordSaves {
            let failedRecord = failedRecordSave.record
            let recordID = failedRecord.recordID.recordName
            var shouldClearServerRecord = false
            
            switch failedRecordSave.error.code {
                
            case .serverRecordChanged:
                // 서버의 레코드를 우리 자신의 로컬 복사본에 병합하겠습니다.
                // `mergeFromServerRecord` 함수가 충돌 해결을 처리합니다.
                guard let serverRecord = failedRecordSave.error.serverRecord else {
                    continue
                }
                let id = UUID(uuidString: recordID)!
                guard var timerRecordItem = await findItemByID(id) else {
                    continue
                }
                timerRecordItem.mergeFromServerRecord(serverRecord)
                try? await coredataDelete(items: [timerRecordItem])
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                
            case .zoneNotFound:
                // Looks like we tried to save a record in a zone that doesn't exist.
                // Let's save that zone and retry saving the record.
                // Also clear the last known server record if we have one, it's no longer valid.
                let zone = CKRecordZone(zoneID: failedRecord.recordID.zoneID)
                newPendingDatabaseChanges.append(.saveZone(zone))
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                shouldClearServerRecord = true
                
            case .unknownItem:
                // We tried to save a record with a locally-cached server record, but that record no longer exists on the server.
                // This might mean that another device deleted the record, but we still have the data for that record locally.
                // We have the choice of either deleting the local data or re-uploading the local data.
                // For this sample app, let's re-upload the local data.
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                shouldClearServerRecord = true
                
            case .networkFailure, .networkUnavailable, .zoneBusy, .serviceUnavailable, .notAuthenticated, .operationCancelled: break
            default:
                // We got an error, but we don't know what it is or how to handle it.
                // If you have any sort of telemetry system, you should consider tracking this scenario so you can understand which errors you see in the wild.
                break
            }
            
            if shouldClearServerRecord {
                /// 타이머 기록 모두 지우기
//                if var contact = self.appData.contacts[contactID] {
//                    contact.lastKnownRecord = nil
//                    self.appData.contacts[contactID] = contact
//                }
            }
        }
        /// coredata에 위임한다.
//        self.syncEngine.state.add(pendingDatabaseChanges: newPendingDatabaseChanges)
//        self.syncEngine.state.add(pendingRecordZoneChanges: newPendingRecordZoneChanges)
        
    }
    
    /// 로그인 시, 가장 최신에 로그인 한 아이클라우드 계정에 대한 정보를 담아놓는다.
    /// 기존 계정으로 재로그인 시: 현재 로컬에 있는 데이터와 동기화한다.
    /// 다른 계정으로 로그인 시: 완전히 새로운 계정의 데이터로 바꾼다.
    ///     추후에 사용자가 기존 작업을 버릴지 말지 선택하게 한다.
    /// 추가 대응방법: 기간 및 작업 별 백업을 만들어 동기화 할 수 있게 만든다.
    func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) async {
        
        // 계정 변경을 처리하는 것은 까다로울 수 있습니다.
        //
        // 사용자가 계정에서 로그아웃했다면, 모든 로컬 데이터를 삭제하고 싶습니다.
        // 하지만 아직 업로드되지 않은 데이터가 있다면 어떻게 해야 할까요?
        // 그 데이터를 유지해야 할까요? 사용자에게 유지 여부를 물어볼까요? 아니면 그냥 삭제할까요?
        //
        // 또 사용자가 새 계정으로 로그인했는데, 로컬에 이미 데이터가 있다면 어떨까요?
        // 그 데이터를 새 계정에 업로드해야 할까요? 아니면 삭제해야 할까요?
        //
        // 마지막으로, 사용자가 로그인했지만 이전에는 다른 계정에 로그인했던 경우는 어떻게 해야 할까요?
        //
        // 이 샘플 앱에서는 상대적으로 단순한 접근 방식을 사용하려고 합니다.
        let shouldDeleteLocalData: Bool
        let shouldReUploadLocalData: Bool
        
        switch event.changeType {
        case .signIn:
            /// 로그인으로 계정 상태가 바뀜
            /// 1. 로컬 데이터는 지우지 않음
            /// 2. 로컬 데이터를 모두 업로드한다.
            shouldDeleteLocalData = false
            shouldReUploadLocalData = true
        case .switchAccounts:
            /// 계정을 바꿈
            /// 1. 모든 로컬 데이터를 지운다.
            /// 2. 로컬 데이터를 업로드 하지 않는다.
            shouldDeleteLocalData = true
            shouldReUploadLocalData = false
        case .signOut:
            /// 로그아웃 함
            /// 1. 로컬 데이터를 지운다.
            /// 2. 로컬 데이터를 업로드 하지 않는다.
            shouldDeleteLocalData = true
            shouldReUploadLocalData = false
            
        @unknown default:
            shouldDeleteLocalData = false
            shouldReUploadLocalData = false
        }
        
        if shouldDeleteLocalData {
//            try? self.deleteLocalData() // This error should be handled, but we'll skip that for brevity in this sample app.
        }
        
        if shouldReUploadLocalData {
//            let recordZoneChanges: [CKSyncEngine.PendingRecordZoneChange] = self.appData.contacts.values.map { .saveRecord($0.ckRecordID) }
//            self.syncEngine.state.add(pendingDatabaseChanges: [ .saveZone(CKRecordZone(zoneName: Contact.zoneName)) ])
//            self.syncEngine.state.add(pendingRecordZoneChanges: recordZoneChanges)
        }
    }
}

// MARK: - Data
extension AnalyzeCoreDataClient {
    
    /// 코어 데이터에는 이미 저장했는데 다시 하는 경우를 대응해야한다.
    func saveTimerRecordItem(client: AnalyzeCoreDataClient, _ timerItem: TimerRecordItem) async {
        /// CoreData에 이 timerItem의 값을 찾는다.
        if await client.findItemByID(timerItem.id) == nil { // nil이면 이 아이디를 기반한 레코드 아이템이 없는 것이다.
            await client.coredataAppend(item: timerItem)
        }
        
        // 클라우드 킷에 추가한다. -> 이건 요청할 것이다.
//        let pendingSaves: [CKSyncEngine.PendingRecordZoneChange] = [ .saveRecord(timerItem.ckRecordID)]
//        self.syncEngine.state.add(pendingRecordZoneChanges: pendingSaves)
    }
    
    func deleteTimerRecordItem(client: AnalyzeCoreDataClient, _ ids: [TimerRecordItem.ID]) async throws {
        let items = try await client.findItemsByID(ids)
        try await client.coredataDelete(items: items)
        let pendingDeletions: [CKSyncEngine.PendingRecordZoneChange] = items.map { .deleteRecord($0.ckRecordID) }
//        self.syncEngine.state.add(pendingRecordZoneChanges: pendingDeletions)
    }
    
//    func fetchCloudData() async throws {
//        try await self.syncEngine.fetchChanges()
//    }
    
//    func deleteContacts(_ ids: [Contact.ID]) throws {
//        let contacts = ids.compactMap { self.appData.contacts[$0] }
//        for id in ids {
//            self.appData.contacts[id] = nil
//        }
//        try self.persistLocalData()
//
//        let pendingDeletions: [CKSyncEngine.PendingRecordZoneChange] = contacts.map { .deleteRecord($0.ckRecordID) }
//        self.syncEngine.state.add(pendingRecordZoneChanges: pendingDeletions)
//    }
    
}
