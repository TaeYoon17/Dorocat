//
//  ICloudSyncControllerProtocol.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation
import ComposableArchitecture

protocol ICloudSyncControllerProtocol {
    func makeReducer(
        state: inout ICloudSyncFeature.State,
        act: ICloudSyncFeature.ViewActionType
    ) -> Effect<ICloudSyncFeature.Action>
    
    func refreshTapped(state: inout ICloudSyncFeature.State) -> Effect<ICloudSyncFeature.Action>
    func isAutomaticSyncEnabled(state: inout ICloudSyncFeature.State, isEnabled: Bool) -> Effect<ICloudSyncFeature.Action>
    func isSyncEnabled(state: inout ICloudSyncFeature.State, isEnabled: Bool) -> Effect<ICloudSyncFeature.Action>
}

extension ICloudSyncControllerProtocol {
    func makeReducer(
        state: inout ICloudSyncFeature.State,
        act: ICloudSyncFeature.ViewActionType
    ) -> Effect<ICloudSyncFeature.Action> {
        switch act {
        case .refreshTapped:
            return refreshTapped(state: &state)
        case .setIsAutomaticSyncEnabled(let isEnabled):
            return isAutomaticSyncEnabled(state: &state, isEnabled: isEnabled)
        case .setIsSyncEnabled(let isEnabled):
            return isSyncEnabled(state: &state, isEnabled: isEnabled)
        }
    }
}
