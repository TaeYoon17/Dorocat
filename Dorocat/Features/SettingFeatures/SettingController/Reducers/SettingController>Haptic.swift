//
//  SettingController>Haptic.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation
import ComposableArchitecture

extension SettingFeature.Controller {
    struct HapticReducer: SettingControllerProtocol {
        @Dependency(\.haptic) var haptic
        typealias Action = SettingFeature.Action
        func notiEnableToggle(state: inout SettingFeature.State, isEnabled: Bool) -> Effect<SettingFeature.Action> {
            .run { _ in
                await haptic.impact(style: .light)
            }
        }
        
        func notiAuthorizedToggle(state: inout SettingFeature.State, isAuthorized: Bool) -> Effect<SettingFeature.Action> {
            .run { _ in
                await haptic.impact(style: .light)
            }
        }
        
        func hapticsToggle(state: inout SettingFeature.State, isOn: Bool) -> Effect<SettingFeature.Action> {
            return .run { _ in
                await haptic.impact(style: .light)
            }
        }
        
        func refundPresentToggle(state: inout SettingFeature.State, isOn: Bool) -> Effect<SettingFeature.Action> {
            .none
        }
        
        func iCloudSyncToggle(state: inout SettingFeature.State, isOn: Bool) -> Effect<SettingFeature.Action> {
            .run { _ in
                await haptic.impact(style: .light)
            }
        }
        
        func openPurchaseTapped(state: inout SettingFeature.State) -> Effect<SettingFeature.Action> {
            .run { _ in
                await haptic.impact(style: .soft)
            }
        }
        
        func feedbackItemTapped(state: inout SettingFeature.State) -> Effect<SettingFeature.Action> {
            .run { _ in
                await haptic.impact(style: .soft)
            }
        }
    }
}
