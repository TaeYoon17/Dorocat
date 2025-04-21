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
//import CloudKit

extension SettingFeature {
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            // 존재하지 않으면 생성한다.
            case registerIcloudSyncScene(ICloudSyncFeature.State = .init())
        }
        
        enum Action {
            case registerIcloudSync(ICloudSyncFeature.Action)
        }
        
        
        var body: some ReducerOf<Self> {
            Scope(state: \.registerIcloudSyncScene, action: \.registerIcloudSync) {
                ICloudSyncFeature()
            }
        }
    }
}

@Reducer
struct SettingFeature {
    @ObservableState struct State: Equatable{
//        var path = StackState<Path.State>()
        var isLaunch = false
        var isNotiAuthorized = false
        var isProUser = false
        var isNotiEnabled = false
        var isSoundEnabled = false
        var isHapticEnabled = false
        var isRefundPresent = false
        var isIcloudSync = false
        var refundTransactionID: Transaction.ID = 0
        var notiAuthType: NotificationStateType = .denied
        var catType: CatType = .doro
        @Presents var purchaseSheet: SettingPurchaseFeature.State?
        @Presents var feedbackSheet: FeedbackFeature.State?
        
        @Presents var alert: AlertState<Action.Alert>?
        
        var appState = DorocatFeature.AppStateType.active
    }
    enum Action {
//        case path(StackAction<Path.State, Path.Action>)
        
        case viewAction(ViewActionType)
        
        case setProUser(Bool)
        case setCatType(CatType)
        case setRefundTransaction(Transaction.ID)
        
        case setNotiType(NotificationStateType)
        case launchAction
        case initAction
        
        case iCloudToggleRouter(iCloudStatusType)
        
        case setAppState(DorocatFeature.AppStateType)
        
        case openIcloudSettingsDestination
        case feedbackSheet(PresentationAction<FeedbackFeature.Action>)
        case purchaseSheet(PresentationAction<SettingPurchaseFeature.Action>)
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case noneExistMailApp
            case showICloudSettings
        }
    }
    
    @Dependency(\.pomoNotification) var notification
    @Dependency(\.haptic) var haptic
    @Dependency(\.initial) var initial
    @Dependency(\.feedback) var feedback
    @Dependency(\.doroStateDefaults) var doroStateDefaults
    @Dependency(\.cat) var cat
    @Dependency(\.store) var store
    @Dependency(\.analyzeAPIClients) var analyzeAPIClients
    
    enum CancelID { case initial, cat }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAction(let viewActionType):
                return viewAction(&state, viewActionType)
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
                        if isAvailable {
                            await send(.viewAction(.setHapticEnabled(await haptic.enable)))
                            await send(.initAction)
                        } else {
                            for await _ in await initial.eventStream() {
                                await send(.viewAction(.setHapticEnabled(true)))
                                await send(.initAction)
                            }
                        }
                    }.cancellable(id: CancelID.initial)
                    let catEffect:Effect<Action> = .run { send in
                        let cat = await doroStateDefaults.getCatType()
                        await send(.setCatType(cat))
                        for await catEvent in await self.cat.catEventStream() {
                            switch catEvent {
                            case .updated(let type): await send(.setCatType(type))
                            }
                        }
                    }.cancellable(id: CancelID.cat)
                    return Effect.merge(notificationEffect,initialEffect,catEffect)
                }
                return .none
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
            case .purchaseSheet: return .none
            case .feedbackSheet: return .none
            case .alert: return .none
            case .setNotiType(let notiType):
                state.notiAuthType = notiType
                return .none
            case .setCatType(let cat):
                state.catType = cat
                return .none
            case .initAction:
                return .cancel(id: CancelID.initial)
            case .setAppState(let appState):
                if appState == .active {
                    return .run { send in
                        if await notification.isDenied {
                            await send(.setNotiType(.denied))
                        } else {
                            let enable = await notification.isEnable
                            await send(.setNotiType(enable ? .enabled : .disabled))
                            await send(.viewAction(.setNotiEnabled(enable)))
                        }
                    }
                }
                return .none
            case .setProUser(let isProUser):
                let prevProUser = state.isProUser
                state.isProUser = isProUser
                return .run { send in
                    if !isProUser && prevProUser != isProUser {
                        await cat.updateCatType(.doro)
                    }
                    await send(.setRefundTransaction(store.refundTransactionID))
                }
            case .setRefundTransaction(let id):
                state.refundTransactionID = id
                return .none
            case .iCloudToggleRouter(let cloudToggleType):
                switch cloudToggleType {
                case .openICloudSignIn:
                    state.isIcloudSync = false
                    state.alert = .openSignIn
                case .openErrorAlert(message: let message):
                    state.isIcloudSync = false
                    state.alert = .openErrorAlert(message: message.rawValue)
                case .startICloudSync:
                    state.isIcloudSync = true
                case .stopICloudSync:
                    state.isIcloudSync = false
                }
                return .none
            /// 상위 네비게이션 링크가 처리할 것이다...
            case .openIcloudSettingsDestination:
                return .none
            }
        }
        .ifLet(\.$purchaseSheet, action: \.purchaseSheet) {
            SettingPurchaseFeature()
        }
        .ifLet(\.$feedbackSheet, action: \.feedbackSheet) {
            FeedbackFeature()
        }
        .ifLet(\.$alert, action: \.alert) { }
    }
}


