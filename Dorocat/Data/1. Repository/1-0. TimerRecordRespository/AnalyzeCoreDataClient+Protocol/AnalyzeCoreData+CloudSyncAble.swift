//
//  AnalyzeCoreData+.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation

extension AnalyzeCoreDataClient: CloudSyncAble {
    
    var lastSyncedDate: Date {
        get {
            guard let data = UserDefaults.standard.data(forKey: "lastSyncedDate"),
                  let date = try? JSONDecoder().decode(Date.self, from: data) else {
                return Date()
            }
            return date
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "lastSyncedDate")
        }
    }
    
    var isICloudSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isIcloudSyncEnabled") }
        set { UserDefaults.standard.setValue(newValue, forKey: "isIcloudSyncEnabled") }
    }
    
    var isAutomaticallySyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isAutomaticallySyncEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isAutomaticallySyncEnabled") }
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
                guard let timerItems = try? await findAllItems() else {
                    assertionFailure("타이머 값이 이상하다!!")
                    return .errorOccured(type: .unknown)
                }
                
                // 1. 동기화가 가능하면 현재까지 로컬 DB에 있는 데이터를 넣는다.
                // 2. refresh를 통해 CloudKit에 저장되어 있는 데이터를 불러온다.
                defer {
                    Task {
                        await syncedDatabase.appendPendingSave(items: timerItems)
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
        let items =  await findAllItems()
        await syncedDatabase.appendPendingSave(items: items)
        let _ = await syncedDatabase.refresh()
    }
}
