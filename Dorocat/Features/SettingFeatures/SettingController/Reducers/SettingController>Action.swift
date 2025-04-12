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
        
        func iCloudSyncToggle(state: inout SettingFeature.State, isOn: Bool) -> Effect<SettingFeature.Action> {
            .run { send in
                guard isOn else {
                    await send(.iCloudToggleRouter(.stopICloudSync), animation: .default)
                    return
                }
                guard let status = try? await CKContainer.default().accountStatus() else {
                    await send(
                        .iCloudToggleRouter(.openErrorAlert(message: .unknown)),
                        animation: .default
                    )
                    return
                }
                let iCloudStatusType: SettingFeature.iCloudStatusType = switch status {
                case .available: .startICloudSync
                case .couldNotDetermine, .temporarilyUnavailable: .openErrorAlert(message: .tryThisLater)
                case .restricted: .openErrorAlert(message: .restricted)
                case .noAccount: .openICloudSignIn
                @unknown default: .openErrorAlert(message: .unknown)
                }
                await send(.iCloudToggleRouter(iCloudStatusType), animation: .default)
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
                state.alert = AlertState(
                    title: {
                        TextState("Can't open the Mail app.")
                    },
                    actions: {
                        ButtonState(role: .cancel) {
                            TextState("Confirm")
                        }
                    },
                    message: {
                        TextState("Download Mail app from the App Store.")
                    }
                )
            }
            return .none
        }
    }
}
