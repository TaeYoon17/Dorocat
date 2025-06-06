//
//  SettingController>Action.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation
import ComposableArchitecture
import CloudKit
import UIKit
import FirebaseAnalytics

extension SettingFeature.Controller {
    struct ActionReducer: SettingControllerProtocol {
        
        @Dependency(\.pomoNotification) var notification
        @Dependency(\.haptic) var haptic
        @Dependency(\.feedback) var feedback
        
        func notiEnableToggle(state: inout SettingFeature.State, isEnabled: Bool) -> Effect<SettingFeature.Action> {
            state.isNotiEnabled = isEnabled
            switch state.notiAuthType {
            case .denied:
                return .none
            case .disabled, .enabled:
                return .run { send in
                    await notification.setEnable(isEnabled)
                }
            }
        }
        
        func notiAuthorizedToggle(state: inout SettingFeature.State, isAuthorized: Bool) -> Effect<SettingFeature.Action> {
            return .run { send in
                if await !notification.isDetermined{
                    let permissionResult = try await notification.requestPermission()
                    if permissionResult {
                        await send(.setNotiType(.enabled))
                        await send(.viewAction(.setNotiEnabled(permissionResult)))
                    }
                }else{
                    if isAuthorized{
                        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else {
                            return
                        }
                        if await UIApplication.shared.canOpenURL(url) {
                            Task { @MainActor in
                                await UIApplication.shared.open(url)
                            }
                        }
                    }
                }
            }
        }
        
        func hapticsToggle(state: inout SettingFeature.State, isOn: Bool) -> Effect<SettingFeature.Action> {
            state.isHapticEnabled = isOn
            return .run { send in
                await haptic.setEnable(isOn)
            }
        }
        
        func refundPresentToggle(state: inout SettingFeature.State, isOn: Bool) -> Effect<SettingFeature.Action> {
            state.isRefundPresent = isOn
            return .none
        }
        
        func openIcloudSetting(state: inout SettingFeature.State) -> Effect<SettingFeature.Action> {
            .run { send in
                await send(.openIcloudSettingsDestination)
            }
        }
        
        
        
        func openPurchaseTapped(state: inout SettingFeature.State) -> Effect<SettingFeature.Action> {
            Analytics.logEvent("Setting Purchase", parameters: nil)
            state.purchaseSheet = .init()
            return .run { send in
                await send(.purchaseSheet(.presented(.initAction)))
            }
        }
        
        func feedbackItemTapped(state: inout SettingFeature.State) -> Effect<SettingFeature.Action> {
            if feedback.isMailFeedbackAvailable {
                state.feedbackSheet = .init()
            } else {
                state.alert = .mailFeedbackNotAvailable
            }
            return .none
        }
    }
}
