//
//  TimerRecordRepository+CloudSyncAble.swift
//  Dorocat
//
//  Created by Greem on 4/16/25.
//

import Foundation

extension TimerRecordRepository: CloudSyncAble {
    
    var lastSyncedDate: Date {
        get {
            let dateResult = defaultsService.loadData(
                type: Date.self,
                key: .cloudSync(.lastSyncedDate)
            )
            
            switch dateResult {
            case .success(let result): return result
            case .failure: return Date()
            }
            
        }
        set {
            defaultsService.saveData(
                value: newValue,
                key: .cloudSync(.lastSyncedDate)
            )
        }
    }
    
    var isICloudSyncEnabled: Bool {
        get {
            let syncResult = defaultsService.load(
                type: Bool.self,
                key: .cloudSync(.cloudSyncEnabled)
            )
            switch syncResult {
            case .success(let result): return result
            case .failure: return false
            }
        }
        set {
            defaultsService.save(
                value: newValue,
                key: .cloudSync(.cloudSyncEnabled)
            )
        }
    }
    
    var isAutomaticallySyncEnabled: Bool {
        get {
            let automaticallyResult = defaultsService.load(
                type: Bool.self,
                key: .cloudSync(.automaticallySyncEnabled)
            )
            switch automaticallyResult {
            case .success(let result): return result
            case .failure: return false
            }
        }
        set {
            defaultsService.save(
                value: newValue,
                key: .cloudSync(.automaticallySyncEnabled)
            )
        }
    }
    
    func synchronizeEventAsyncStream() async -> AsyncStream<SynchronizeEvent> {
        self.synchronizeEvent
    }
    
    /// 유저가 자동 동기화를 설정한다.
    func setAutomaticSync(_ state: Bool) async {
        if isAutomaticallySyncEnabled != state {
            self.isAutomaticallySyncEnabled = state
            await syncedDatabase.setAutomaticallySync(isOn: state)
        }
    }
    
    /// 유저가 아이클라우드 동기화를 설정한다.
    func setICloudAccountState(_ state: Bool) async -> iCloudStatusTypeDTO {
        if state {
            guard let status = await syncedDatabase.getAccountStatus() else {
                return .errorOccured(type: .tryThisLater)
            }
            /// 계정이 가능하지 않으면 자동 동기화를 끈다.
            defer {
                Task {
                    if(status != .available) {
                        self.isICloudSyncEnabled = false
                        await setAutomaticSync(false)
                    }
                }
            }
            
            switch status {
            case .available:
                let timerItems: [TimerRecordItem] = await findAllItems()
                let dtos = timerItems.map { CKTimerRecordDTO(item: $0) }
                
                // 1. 동기화가 가능하면 현재까지 로컬 DB에 있는 데이터를 넣는다.
                // 2. refresh를 통해 CloudKit에 저장되어 있는 데이터를 불러온다.
                defer {
                    Task {
                        await syncedDatabase.appendPendingSave(items: dtos)
                        await refresh()
                    }
                }
                self.isICloudSyncEnabled = true
                return .startICloudSync
            case .noAccount:
                return .shouldICloudSignIn
            case .couldNotDetermine, .temporarilyUnavailable:
                return .errorOccured(type: .tryThisLater)
            case .restricted:
                return .errorOccured(type: .restricted)
            @unknown default:
                return .errorOccured(type: .unknown)
            }
        } else {
            self.isAutomaticallySyncEnabled = false
            self.isICloudSyncEnabled = false
            return .stopICloudSync
        }
    }
    
    func refresh() async  {
        let items: [TimerRecordItem] =  await findAllItems()
        let dtos = items.map { CKTimerRecordDTO(item: $0) }
        await syncedDatabase.appendPendingSave(items: dtos)
        let _ = await syncedDatabase.refresh()
    }
}
