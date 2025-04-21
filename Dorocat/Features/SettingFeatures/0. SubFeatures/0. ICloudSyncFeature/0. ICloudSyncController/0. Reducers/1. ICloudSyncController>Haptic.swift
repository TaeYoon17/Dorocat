//
//  ICloudSyncController>Haptic.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation
import ComposableArchitecture

extension ICloudSyncFeature {
    struct HapticReducer: ICloudSyncControllerProtocol {
        @Dependency(\.haptic) var haptic
        
        func refreshTapped(state: inout ICloudSyncFeature.State) -> Effect<ICloudSyncFeature.Action> {
            return .run { _ in
                await haptic.impact(style: .light)
            }
        }
        
        func isAutomaticSyncEnabled(state: inout ICloudSyncFeature.State, isEnabled: Bool) -> Effect<ICloudSyncFeature.Action> {
            return .run { _ in
                await haptic.impact(style: .light)
            }
        }
        
        func isSyncEnabled(state: inout ICloudSyncFeature.State, isEnabled: Bool) -> Effect<ICloudSyncFeature.Action> {
            return .run { _ in
                await haptic.impact(style: .light)
            }
        }
    }
}
