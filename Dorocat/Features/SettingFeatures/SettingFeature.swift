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
        var isLaunch = false
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
        case launchAction
        case initAction
        case openPurchase
    }
    @Dependency(\.pomoNotification) var notification
    @Dependency(\.haptic) var haptic
    @Dependency(\.initial) var initial
    enum CancelID{case initial}
    var body: some ReducerOf<Self>{
        Reduce{ state,action in
            switch action{
            case .launchAction:
                if !state.isLaunch{
                    state.isLaunch = true
                    let notificationEffect:Effect<Action> = .run { send in
                        let authStatusAuthorized = await notification.getUserNotiAuthroizationStatus()
                        if authStatusAuthorized{
                            let enable = await notification.enable
                            await send(.setNotiType(enable ? .enabled : .disabled))
                            await send(.setNotiEnabled(enable))
                        }else{
                            await send(.setNotiType(.unAuthorized))
                        }
                    }
                    let initialEffect:Effect<Action> = .run { send in
                        let isAvailable = await initial.isUsed // 이미 초기 설정이 끝났다... 기존에 있는 값을 가져오면 됨
                        if isAvailable{
                            await send(.setHapticEnabled(await haptic.enable))
                            await send(.initAction)
                        }else{
                            for await _ in await initial.eventStream(){
                                await send(.setHapticEnabled(true))
                                await send(.initAction)
                            }
                        }
                    }.cancellable(id: CancelID.initial)
                    return Effect.merge(notificationEffect,initialEffect)
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
            case .initAction:
                return .cancel(id: CancelID.initial)
            }
        }
        .ifLet(\.$purchaseSheet, action: \.purchaseSheet){
            SettingPurchaseFeature()
        }
    }
}
