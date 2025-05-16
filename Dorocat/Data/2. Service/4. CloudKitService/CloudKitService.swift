//
//  SyncedDatabase.swift
//  SyncEngine
//

import CloudKit
import Foundation
import os.log
/// CKContainer 연동 접근 방법
/// 1. 로컬 데이터는 CoreData에 둔다.
/// 2. 사용자에게 iCloud 연동을 할 것인지 물어본다..! => 유료가 아니라면 유료를 유도하자
///     2-1. 앱을 처음 깐 사용자에게는 온보딩에서 물어보자
///     2-2. 앱을 이미 사용 중인 사용자에게는 시트로 물어보자 (한 번만 띄우는 시트...)
/// 3. iCloud 연동을 할 경우임) 처음 Cloud 연동 시, 기존 CloudKit에 존재하는 모든 데이터를 fetch 한다. - (비동기 작업으로 진행)
/// 4. iCloud 연동을 하지 않을 경우임) 기존 CoreData 기반 데이터들을 모두 가져온다.
/// - 추가할 화면
/// 1. 동기화를 할 것인가 / 아이클라우드에서 사용한 데이터가 얼마인가? -> 이게 되려나?
///     2.0 동기화를 한다면 수동 업데이트 버튼을 누르게 한다.
///     2.1 동기화를 한다면 네트워크 상관없이 할 것인가?

extension CKRecord {
    var convertIDToRecordType: CKConstants.Label {
        CKConstants.Label(rawValue: self.recordType)!
    }
}
extension CKRecord.RecordType {
    var convertToEntityType: CKConstants.Label {
        CKConstants.Label(rawValue: self)!
    }
}

final actor CloudKitService : Sendable {
    private var userDefaultsSerialization: String { "stateSerialization" }
    private static var ckContainerIdentifier: String { "iCloud.com.tistory.arpple.Dorocat" }
//    private weak var coreDataClient: AnalyzeCoreDataClient!
    /// iCloud 컨테이너를 설정한다.
    private static let container: CKContainer = CKContainer(identifier: ckContainerIdentifier)
    private var _syncEngine: CKSyncEngine?
    
    private var automaticallySync: Bool = false { // 일단 자동 싱크를 막는다. 추후에 수정해야할 필요 있음
        didSet {
            if automaticallySync { // 자동 싱크를 true로 할 경우
                initializeSyncEngine()
            } else { // 자동 싱크를 false로 바꿀 경우
                initializeSyncEngine()
            }
        }
    }
    
    private(set) var syncHandlers: [CKConstants.Label : (any CloudKitServicingHandler)?] = [:]
    private(set) var pendingItems: [CKRecord.ID : CKConstants.Label] = [:]
    
    var stateSerialization: CKSyncEngine.State.Serialization? {
        get {
            guard let data = UserDefaults.standard.data(forKey: self.userDefaultsSerialization),
                  let serialization = try? JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: data) else {
                return nil
            }
            return serialization
        }
        set {
            guard let newValue = newValue else { return }
            UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: self.userDefaultsSerialization)
        }
    }
    
    var syncEngine: CKSyncEngine {
        if _syncEngine == nil {
            self.initializeSyncEngine()
        }
        return _syncEngine!
    }
    
    private func initializeSyncEngine() {
        var configuration = CKSyncEngine.Configuration(
            database: Self.container.privateCloudDatabase,
            stateSerialization: self.stateSerialization,
            delegate: self
        )
        configuration.automaticallySync = self.automaticallySync
        let syncEngine = CKSyncEngine(configuration)
        _syncEngine = syncEngine
        Logger.database.log("Initialized sync engine: \(syncEngine)")
    }
    
    func setAutomaticallySync(isOn: Bool) {
        self.automaticallySync = isOn
    }
    
    func setStateSerialization(_ event: CKSyncEngine.Event.StateUpdate) {
        self.stateSerialization = event.stateSerialization
    }
    
    func getAccountStatus() async -> CKAccountStatus? {
        try? await CKContainer.default().accountStatus()
    }
    
    func appendSyncHandler(key: CKConstants.Label, value: any CloudKitServicingHandler) {
        self.syncHandlers[key] = value
    }
    
    func removeTarget(id: CKRecord.ID) async {
        self.pendingItems.removeValue(forKey: id)
    }
    
    func appendTarget(id: CKRecord.ID, entityType: CKConstants.Label) {
        self.pendingItems[id] = entityType
    }
    
    func refresh() async -> Date {
        try? await syncEngine.fetchChanges()
        try? await syncEngine.sendChanges()
        return Date.now
    }
}

extension CloudKitService {
    /// 델리게이트에게 서버로 보낼 다음 레코드 변경 집합을 제공하도록 요청합니다.
    /// 배치 => 한번에 보낼 그릇, 버퍼와 비슷하다.
    func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        /// 변화를 일으키는 작업들에 대한 Scope들
        let scope: CKSyncEngine.SendChangesOptions.Scope = context.options.scope
        
        /// 대기중인 작업들 중 변화가 필요한 것들만 가져온다. => 생성이랑 삭제 작업이 될 것이다...
        let changes: [CKSyncEngine.PendingRecordZoneChange] = syncEngine.state.pendingRecordZoneChanges.filter {
            scope.contains($0)
        }
        let batch = await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: changes) { recordID in
            guard let type = await self.pendingItems[recordID] else {
                return nil
            }
            await self.removeTarget(id: recordID)
            guard let writable: CKWritable = await syncHandlers[type]??.requestCKWritableForPendingRecord(id: recordID.recordName) else {
                syncEngine.state.remove(pendingRecordZoneChanges: [ .saveRecord(recordID) ])
                return nil
            }
            let record = CKRecord(recordType: writable.recordType, recordID: recordID)
            writable.populateRecord(record)
            return record
        }
        return batch
    }
}




// MARK: - Data
extension CloudKitService {
    
    /// CloudKit에 업로드할 값들을 추가한다.
    func appendPendingSave(items: [CKReadable], directlySend: Bool = false) async {
        var pendingSaves: [CKSyncEngine.PendingRecordZoneChange] = []
        for item in items {
            let recordEntityType = CKConstants.Label(rawValue: item.recordType)!
            self.appendTarget(id: item.ckRecordID, entityType: recordEntityType)
            pendingSaves.append(.saveRecord(item.ckRecordID))
        }
        
        self.syncEngine.state.add(pendingRecordZoneChanges: pendingSaves)
        if directlySend {
            try? await self.syncEngine.sendChanges()
        }
    }
    
    /// CloudKit에 삭제할 값들을 추가한다.
    func appendPendingDelete(items: [CKReadable]) {
        let pendingDeletions: [CKSyncEngine.PendingRecordZoneChange] = items.map { .deleteRecord($0.ckRecordID) }
        self.syncEngine.state.add(pendingRecordZoneChanges: pendingDeletions)
    }
    
    func updateSyncItem(_ item: any CKConvertible) async throws {
        let record = CKRecord(recordType: item.recordType, recordID: item.ckRecordID)
        /// 레코드에 이 로컬 값을 쓴다.
        item.populateRecord(record)
        _ = try await syncEngine.database.modifyRecords(saving: [record], deleting: [], savePolicy: .allKeys)
    }
}
