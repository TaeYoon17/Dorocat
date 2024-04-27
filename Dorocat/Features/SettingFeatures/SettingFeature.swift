//
//  SettingFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture
import UIKit
@Reducer struct SettingFeature{
    enum NotificationStateType{
        case unAuthorized
        case enabled
        case disabled
    }
    @ObservableState struct State: Equatable{
        var isInit = false
        var isNotiAuthorized = false
        var isNotiEnabled = false
        var isSoundEnabled = false
        var isHapticEnabled = false
        var notiAuthType: NotificationStateType = .unAuthorized
        @Presents var purchaseSheet: SettingPurchaseFeature.State?
    }
    enum Action:Equatable{
        case setNotiAuthorized(Bool)
        case setNotiEnabled(Bool)
        case setSoundEnabled(Bool)
        case setHapticEnabled(Bool)
        case ratingItemTapped
        case feedbackItemTapped
        case setNotiType(NotificationStateType)
        case purchaseSheet(PresentationAction<SettingPurchaseFeature.Action>)
    case initAction
        case openPurchase
    }
    @Dependency(\.pomoNotification) var notification
    @Dependency(\.haptic) var haptic
    var body: some ReducerOf<Self>{
        Reduce{ state,action in
            switch action{
            case .initAction:
                if !state.isInit{
                    state.isInit = true
                    return .run { send in
                        let authStatusAuthorized = await notification.getUserNotiAuthroizationStatus()
                        if authStatusAuthorized{
                            let enable = await notification.enable
                            await send(.setNotiType(enable ? .enabled : .disabled))
                            await send(.setNotiEnabled(enable))
                        }else{
                            await send(.setNotiType(.unAuthorized))
                        }
                    }
                }
                return .none
            case .purchaseSheet: return .none
            case .openPurchase:
                state.purchaseSheet = .init()
                let hapticEffect:Effect<Action> = .run { send in await haptic.impact(style: .soft) }
                return .run{ send in
                    await send(.purchaseSheet(.presented(.initAction)))
                }.merge(with: hapticEffect)
            case .setNotiType(let notiType):
                state.notiAuthType = notiType
                return .none
            case .setNotiAuthorized(let isAuthorized):
                if isAuthorized{
                    guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return .none }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
                return .run{ send in
                    await haptic.impact(style: .light)
                }
            case .setNotiEnabled(let isEnabled):
                state.isNotiEnabled = isEnabled
                let hapticEffect: Effect<Action> = .run { send in
                    await haptic.impact(style: .light)
                }
                switch state.notiAuthType{
                case .unAuthorized: return hapticEffect
                case .disabled,.enabled: return .run { send in
                     await notification.setEnable(isEnabled)
                    }.merge(with: hapticEffect)
                }
            case .setSoundEnabled(let isSoundEnabled):
                state.isSoundEnabled = isSoundEnabled
                return .run { send in
                    await haptic.impact(style: .light)
                }
            case .setHapticEnabled(let isHapticEnabled):
                state.isHapticEnabled = isHapticEnabled
                return .run { send in
                    await haptic.setEnable(isHapticEnabled)
                    await haptic.impact(style: .light)
                }
            case .ratingItemTapped:
                return .run{ send in
                    await haptic.impact(style: .soft)
                }
            case .feedbackItemTapped:
                return .run { send in
                    await haptic.impact(style: .soft)
                }
            }
        }
        .ifLet(\.$purchaseSheet, action: \.purchaseSheet){
            SettingPurchaseFeature()
        }
    }
}
