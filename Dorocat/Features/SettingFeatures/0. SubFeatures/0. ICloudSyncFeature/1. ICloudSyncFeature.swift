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
        case viewAction(ViewActionType)
        
        case iCloudStatusRouter(iCloudStatusTypeDTO)
        
        case alert(PresentationAction<Alert>)
        enum Alert {
            case showICloudSettings
        }
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
                    return .none
                case .stopICloudSync:
                    state.isSyncEnabled = false
                    return .none
                }
            }
        }
        .ifLet(\.$alert, action: \.alert) { }
    }
}
