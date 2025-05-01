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
        
        @Presents var alert: AlertState<Action.Alert>?
        
    }
    enum Action {
        case onAppear
        case viewAction(ViewActionType)
        
        case iCloudStatusRouter(iCloudStatusTypeDTO)
        
        case setToggleEnabled(isSynced: Bool, isAutomaticallySynced: Bool)
        
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case showICloudSettings
            case enableAutomaticSync(Bool)
        }
    }
    
    @Dependency(\.analyzeAPIClients) var analyzeAPIClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            print(action)
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
                return .run { send in
                    let isAutomaticallySyncEnabled = await analyzeAPIClient.isAutomaticallySyncEnabled
                    let isSyncEnabled = await analyzeAPIClient.isICloudSyncEnabled
                    await send(
                        .setToggleEnabled(isSynced: isSyncEnabled, isAutomaticallySynced: isAutomaticallySyncEnabled),
                        animation: .default
                    )
                }
            case .setToggleEnabled(isSynced: let isSynced, isAutomaticallySynced: let isAutomatically):
                state.isSyncEnabled = isSynced
                state.isAutomaticSyncEnabled = isAutomatically
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert) { }
    }
}
