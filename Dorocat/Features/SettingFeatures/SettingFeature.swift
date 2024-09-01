//
//  SettingFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture
import UIKit
import StoreKit
import FirebaseAnalytics
@Reducer struct SettingFeature{
    enum NotificationStateType{
        case denied
        case enabled
        case disabled
    }
    @ObservableState struct State: Equatable{
        var isLaunch = false
        var isNotiAuthorized = false
        var isProUser = false
        var isNotiEnabled = false
        var isSoundEnabled = false
        var isHapticEnabled = false
        var isRefundPresent = false
        var refundTransactionID: Transaction.ID = 0
        var notiAuthType: NotificationStateType = .denied
        var catType: CatType = .doro
        @Presents var purchaseSheet: SettingPurchaseFeature.State?
        @Presents var feedbackSheet: FeedbackFeature.State?
        @Presents var alert: AlertState<Action.Alert>?
        var appState = DorocatFeature.AppStateType.active
    }
    enum Action:Equatable{
        case setNotiAuthorized(Bool)
        case setNotiEnabled(Bool)
        case setSoundEnabled(Bool)
        case setHapticEnabled(Bool)
        case setProUser(Bool)
        case setRefundPresent(Bool)
        case setRefundTransaction(Transaction.ID)
        
        
        case setCatType(CatType)
        
        case openPurchase
        case ratingItemTapped
        case feedbackItemTapped
        
        case setNotiType(NotificationStateType)
        case launchAction
        case initAction
        
        case setAppState(DorocatFeature.AppStateType)
        case feedbackSheet(PresentationAction<FeedbackFeature.Action>)
        case purchaseSheet(PresentationAction<SettingPurchaseFeature.Action>)
        case alert(PresentationAction<Alert>)
        enum Alert:Equatable{
            case noneExistMailApp
        }
    }
    @Dependency(\.pomoNotification) var notification
    @Dependency(\.haptic) var haptic
    @Dependency(\.initial) var initial
    @Dependency(\.feedback) var feedback
    @Dependency(\.pomoDefaults) var pomoDefaults
    @Dependency(\.cat) var cat
    @Dependency(\.store) var store
    enum CancelID{case initial, cat}
    var body: some ReducerOf<Self>{
        Reduce{ state,action in
            switch action{
            case .launchAction:
                if !state.isLaunch{
                    state.isLaunch = true
                    let notificationEffect:Effect<Action> = .run { send in
                        if await !notification.isDetermined{
                            await send(.setNotiType(.denied))
                        }
                    }
                    let initialEffect:Effect<Action> = .run { send in
                        // 이미 초기 설정이 끝났다... 기존에 있는 값을 가져오면 됨
                        let isAvailable = await initial.isUsed
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
                    let catEffect:Effect<Action> = .run { send in
                        let cat = await pomoDefaults.selectedCat
                        await send(.setCatType(cat))
                        for await catEvent in await self.cat.catEventStream(){
                            switch catEvent{
                            case .updated(let type): await send(.setCatType(type))
                            }
                        }
                    }.cancellable(id: CancelID.cat)
                    return Effect.merge(notificationEffect,initialEffect,catEffect)
                }
                return .none
            case .purchaseSheet: return .none
            case .feedbackSheet: return .none
            case .alert: return .none
            case .openPurchase:
                Analytics.logEvent("Setting Purchase", parameters: nil)
                state.purchaseSheet = .init()
                let hapticEffect:Effect<Action> = .run { send in await haptic.impact(style: .soft) }
                return .run{ send in
                    await send(.purchaseSheet(.presented(.initAction)))
                }.merge(with: hapticEffect)
            case .setNotiType(let notiType):
                state.notiAuthType = notiType
                return .none
            case .setNotiAuthorized(let isAuthorized):
                return .run{ send in
                    if await !notification.isDetermined{
                        let permissionResult = try await notification.requestPermission()
                        if permissionResult{
                            await send(.setNotiType(.enabled))
                            await send(.setNotiEnabled(permissionResult))
                        }
                    }else{
                        if isAuthorized{
                            guard let url = await
                                    URL(string: UIApplication.openNotificationSettingsURLString) else { return }
                            if await UIApplication.shared.canOpenURL(url) {
                                Task{@MainActor in
                                    await UIApplication.shared.open(url)
                                }
                            }
                        }
                    }
                }
                .merge(with: .run(operation: { send in
                    await haptic.impact(style: .light)
                }))
            case .setNotiEnabled(let isEnabled):
                state.isNotiEnabled = isEnabled
                let hapticEffect: Effect<Action> = .run { send in
                    await haptic.impact(style: .light)
                }
                switch state.notiAuthType{
                case .denied:
                    return hapticEffect
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
            case .setCatType(let cat): state.catType = cat
                return .none
            case .ratingItemTapped:
                return .run{ send in
                    await haptic.impact(style: .soft)
                }
            case .feedbackItemTapped:
                if feedback.isMailFeedbackAvailable{
                    state.feedbackSheet = .init()
                }else{
                    state.alert = AlertState(title: {
                        TextState("Can't open the Mail app.")
                    },actions: {
                        ButtonState(role: .cancel) {
                            TextState("Confirm")
                        }
                    })
                }
                return .run { send in
                    await haptic.impact(style: .soft)
                }
            case .initAction:
                return .cancel(id: CancelID.initial)
            case .setAppState(let appState):
                if appState == .active{
                    return .run { send in
                        if await notification.isDenied{
                            await send(.setNotiType(.denied))
                        }else{
                            let enable = await notification.isEnable
                            await send(.setNotiType(enable ? .enabled : .disabled))
                            await send(.setNotiEnabled(enable))
                        }
                    }
                }
                return .none
            case .setProUser(let isProUser):
                let prevProUser = state.isProUser
                state.isProUser = isProUser
                return .run { send in
                    if !isProUser && prevProUser != isProUser{
                        await cat.updateCatType(.doro)
                    }
                    await send(.setRefundTransaction(store.refundTransactionID))
                }
            case .setRefundPresent(let isRefund):
                state.isRefundPresent = isRefund
                return .none
            case .setRefundTransaction(let id):
                state.refundTransactionID = id
                return .none
            }
        }
        .ifLet(\.$purchaseSheet, action: \.purchaseSheet){
            SettingPurchaseFeature()
        }
        .ifLet(\.$feedbackSheet, action: \.feedbackSheet){
            FeedbackFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
