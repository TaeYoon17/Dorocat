//
//  DorocatFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture


extension DorocatFeature {
    @Reducer
    struct DoroPath {
        
        @ObservableState
        enum State: Equatable {
            // 존재하지 않으면 생성한다.
            case registerICloudSettingScene(ICloudSyncFeature.State = .init())
        }
        
        enum Action {
            case iCloudSetting(ICloudSyncFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.registerICloudSettingScene, action: \.iCloudSetting) {
                ICloudSyncFeature()
            }
        }
    }
}


@Reducer
struct DorocatFeature {
    
    @ObservableState
    struct State: Equatable {
        
        var path = StackState<DoroPath.State>()
        
        var pageSelection: PageType = .timer
        var appState = AppStateType.active
        var guideState = Guides()
        var isAppLaunched = false
        var showPageIndicator = true
        var catType:CatType = .doro
        var isProUser: Bool = false
        
        @Presents var alert: AlertState<Action.Alert>?
        
        //MARK: -- 하위 뷰의 State 들...
        var anylzeState = AnalyzeFeature.State()
        var timerState = MainFeature.State()
        var settingState = SettingFeature.State()
    }
    
    enum Action {
        
        case actionPath(StackAction<DorocatFeature.DoroPath.State, DorocatFeature.DoroPath.Action>)
        
        case pageMove(PageType)
        case setAppState(AppStateType)
        case setProUser(Bool)
        case launchAction
        case initialAction
        case onBoardingTapped
        case onBoardingWillTap
        case requestIcloudSync
        case failedIcloudSync
        
        case timer(MainFeature.Action)
        case analyze(AnalyzeFeature.Action)
        case setting(SettingFeature.Action)
        case setGuideStates(Guides)
        case setActivityAction(prev:TimerActivityType,next:TimerActivityType)
        
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case enableIcloudSync
        }
    }
    
    @Dependency(\.guideDefaults) var guideDefaults
    @Dependency(\.haptic) var haptic
    @Dependency(\.initial) var initial
    @Dependency(\.pomoNotification) var notification
    @Dependency(\.pomoSession) var session
    @Dependency(\.pomoLiveActivity) var liveActivity
    @Dependency(\.doroStateDefaults) var doroStateDefaults
    @Dependency(\.timer.background) var timerBackground
    @Dependency(\.store) var store
    @Dependency(\.analyzeAPIClients) var analyzeAPIClients
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .pageMove(let type): return pageMoveReducer(state: &state, type: type)
            case .setAppState(let appState):
                state.appState = appState
                return .run { send in
                    await send(.timer(.setAppState(appState)))
                    await send(.setting(.setAppState(appState)))
                }
            case .setProUser(let isProUser):
                state.isProUser = isProUser
                return .run { send in
                    await send(.timer(.setProUser(isProUser)))
                    await send(.setting(.setProUser(isProUser)))
                }
            case .launchAction: return launchReducer(state: &state)
            case .timer(let action): return timerFeatureReducer(state: &state, subAction: action)
            case .analyze(let action):return analyzeFeatureReducer(state: &state, subAction: action)
            case .setting(let action): return settingFeatureReducer(state: &state, subAction: action)
            case .setGuideStates(let guides):
                return .run{[guides] send in
                    await self.guideDefaults.set(guide: guides)
                    await send(.timer(.setGuideState(guides)))
                }
            case .onBoardingTapped:
                var guide = state.guideState
                guide.onBoarding = true
                return .run { [guide] send in
                    await send(.setGuideStates(guide))
                    // 노티피케이션 권한 요청
                    _ = try await notification.requestPermission()
                    // 아이클라우드 동기화 요청
                    await send(.requestIcloudSync)
                }
            case .onBoardingWillTap:
                return .run { send in
                    await haptic.impact(style: .soft)
                }
            case .initialAction:
                return .run { send in
                    await haptic.setEnable(true)
                    await notification.setEnable(true)
                }
            case .setActivityAction(let prev, let next):
                return timerActivityReducer(state: &state, prev: prev, next: next)
            case .actionPath(_): return .none
            case .alert(.presented(.enableIcloudSync)):
                return .run { send in
                    try await analyzeAPIClients.initAction()
                    let iCloudStatusTypeDTO = await analyzeAPIClients.setICloudAccountState(true)
                    switch iCloudStatusTypeDTO {
                    case .startICloudSync:
                        await analyzeAPIClients.setAutomaticSync(true)
                    default:
                        await send(.failedIcloudSync)
                    }
                }
            case .alert: return .none
            case .requestIcloudSync:
                state.alert = .requestIcloudSyncAlert
                return .none
            case .failedIcloudSync:
                state.alert = .failedIcloudSyncAlert
                return .none
            }
        }
        .forEach(\.path, action: \.actionPath) {
            DoroPath()
        }
        .ifLet(\.$alert, action: \.alert) { }
        Scope(state: \.anylzeState,action: /DorocatFeature.Action.analyze) {
            AnalyzeFeature()
        }
        Scope(state: \.timerState, action: /DorocatFeature.Action.timer) {
            MainFeature()
        }
        Scope(state: \.settingState,action: /DorocatFeature.Action.setting) {
            SettingFeature()
        }
    }
}

fileprivate extension AlertState where Action == DorocatFeature.Action.Alert {
    static let requestIcloudSyncAlert = AlertState(
        title: {
            TextState("Enable iCloud Sync?")
        },
        actions: {
            ButtonState(role: .none, action: .send(.enableIcloudSync)) {
                TextState("Enable")
            }
            ButtonState(role: .cancel) {
                TextState("Disable")
            }
        },
        message: {
            TextState(
                "Your timer records are automatically synchronized with iCloud.\nThis setting can be adjusted in the Settings"
            )
        }
    )
    static let failedIcloudSyncAlert = AlertState(
        title: {
            TextState("Failed to sync iCloud")
        },
        actions: {
            ButtonState(role: .cancel) {
                TextState("Close")
            }
        },
        message: {
            TextState(
                "Configure it in Settings"
            )
        }
    )
}
