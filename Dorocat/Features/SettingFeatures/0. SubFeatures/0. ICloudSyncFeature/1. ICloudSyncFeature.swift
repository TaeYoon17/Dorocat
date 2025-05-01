//
//  ICloudSyncFeature.swift
//  Dorocat
//
//  Created by Greem on 4/17/25.
//

import Foundation
import ComposableArchitecture
import UIKit
import CloudKit

extension ICloudSyncFeature {
    enum ViewActionType: Equatable {
        case setIsSyncEnabled(_ isEnabled: Bool)
        case setIsAutomaticSyncEnabled(_ isEnabled: Bool)
        case refreshTapped
    }
}

@Reducer
struct ICloudSyncFeature {
    
    @ObservableState
    struct State: Equatable {
        
        var isSyncEnabled: Bool = false
        var isAutomaticSyncEnabled: Bool = false
        var isLoading: Bool = false
        var elapsedTime: String = "1 seconds ago..."
        fileprivate var syncedDate: Date = Date()
        
        
        @Presents var alert: AlertState<Action.Alert>?
        
    }
    
    enum Action {
        case onAppear
        case viewAction(ViewActionType)
        
        case iCloudStatusRouter(iCloudStatusTypeDTO)
        
        case setSyncedDate(Date)
        case setToggleEnabled(isSynced: Bool, isAutomaticallySynced: Bool)
        case updateElapsedTime
        case setIsLoadingSynchronize(isOn: Bool)
        
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case showICloudSettings
            case enableAutomaticSync(Bool)
        }
    }
    
    @Dependency(\.analyzeAPIClients) var analyzeAPIClient
    
    enum CancelID {
        case elapsedTimer
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAction(let viewAction):
                return self.viewAction(state: &state, act: viewAction)
            case .alert(.presented(.showICloudSettings)):
                return .run { send in
                    guard let url = URL(string:"App-Prefs:root=CASTLE") else {
                        return
                    }
                    if await UIApplication.shared.canOpenURL(url) {
                        Task { @MainActor in
                            await UIApplication.shared.open(url)
                        }
                    }
                }
            case .alert(.presented(.enableAutomaticSync(let isEnabled))):
                /// 일단은 뷰 액션을 넘긴다.
                return .run { send in
                    await send(.viewAction(.setIsAutomaticSyncEnabled(isEnabled)),animation: .default)
                }
            case .alert: return .none
            case .iCloudStatusRouter(let statusType):
                switch statusType {
                case .errorOccured(type: let type):
                    state.alert = .openErrorAlert(title: "Can not open iCloud", message: type.rawValue)
                    return .none
                case .shouldICloudSignIn:
                    state.alert = .openSignIn
                    return .none
                case .startICloudSync:
                    state.isSyncEnabled = true
                    state.alert = .openAutoSyncEnable
                    return .none
                case .stopICloudSync:
                    state.isSyncEnabled = false
                    return .none
                }
            case .onAppear:
                return .merge(
                    .run { send in
                        let isAutomaticallySyncEnabled = await analyzeAPIClient.isAutomaticallySyncEnabled
                        let isSyncEnabled = await analyzeAPIClient.isICloudSyncEnabled
                        await send(
                            .setToggleEnabled(isSynced: isSyncEnabled, isAutomaticallySynced: isAutomaticallySyncEnabled),
                            animation: .default
                        )
                    },
                    .run(operation: { send in
                        let continuousClock = SuspendingClock()
                        while true {
                            try await continuousClock.sleep(for: .seconds(1))
                            await send(.updateElapsedTime)
                        }
                    }).cancellable(id: CancelID.elapsedTimer),
                    .run(operation: { send in
                        for await event in await analyzeAPIClient.synchronizeEventAsyncStream() {
                            switch event {
                            case .start: await send(.setIsLoadingSynchronize(isOn: true))
                            case .end:
                                let date = await analyzeAPIClient.lastSyncedDate
                                await send(.setIsLoadingSynchronize(isOn: false))
                                await send(.setSyncedDate(date))
                            }
                        }
                    })
                )
            case .updateElapsedTime:
                state.elapsedTime = Date.timeDifferenceString(from: state.syncedDate)
                return .none
            case .setToggleEnabled(isSynced: let isSynced, isAutomaticallySynced: let isAutomatically):
                state.isSyncEnabled = isSynced
                state.isAutomaticSyncEnabled = isAutomatically
                return .none
            case .setIsLoadingSynchronize(isOn: let isOn):
                state.isLoading = isOn
                return .none
            case .setSyncedDate(let date):
                state.syncedDate = date
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert) { }
    }
}

fileprivate extension Date {
    
    static func timeDifferenceString(from earlier: Date, to later: Date = Date()) -> String {
        let seconds = Int(later.timeIntervalSince(earlier))
        
        if seconds < 60 {
            return "\(seconds) seconds ago..."
        }
        
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes) minutes ago..."
        }
        
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours < 3 {
            return "\(hours) hours \(remainingMinutes) minutes ago..."
        }
        
        if hours < 24 {
            return "\(hours) hours ago..."
        }
        
        let days = hours / 24
        if days < 7 {
            return "\(days) days ago"
        }
        
        return "Over 7 days ago..."
    }

}
