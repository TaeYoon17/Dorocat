//
//  ICloudSyncController>Action.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation
import ComposableArchitecture

import CloudKit

extension ICloudSyncFeature {
    struct ActionReducer: ICloudSyncControllerProtocol {
        @Dependency(\.analyzeAPIClients) var analyzeAPIClient
        func refreshTapped(state: inout ICloudSyncFeature.State) -> Effect<ICloudSyncFeature.Action> {
            if !state.isLoading {
                state.isLoading = true
                return .none
            }
            return .none
        }
        
        func isAutomaticSyncEnabled(state: inout ICloudSyncFeature.State, isEnabled: Bool) -> Effect<ICloudSyncFeature.Action> {
            state.isAutomaticSyncEnabled = isEnabled
            return .none
        }
        
        func isSyncEnabled(state: inout ICloudSyncFeature.State, isEnabled: Bool) -> Effect<ICloudSyncFeature.Action> {
            .run { send in
                let status = await analyzeAPIClient.getICloudAccountState(isEnabled)
                await send(.iCloudStatusRouter(status), animation: .default)
            }
        }
    }
}
