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
    
    enum AppStateType: Hashable, Equatable {
        case inActive
        case active
        case background
    }
    
    enum PageType: String, Hashable, Equatable, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        
        case analyze
        case timer
        case setting
    }
    
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
        var timerState = PomoTimerFeature.State()
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
        
        case openRequestIcloudSyncSheet
        case openFailedIcloudSyncSheet
        
        case timer(PomoTimerFeature.Action)
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
    @Dependency(\.doroSession) var session
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
                return .run{ [guides] send in
                    await self.guideDefaults.set(guide: guides)
                    await send(.timer(.setGuideState(guides)))
                }
            case .onBoardingTapped:
                var guide = state.guideState
                guide.onBoardingFinished = true
                return .run { [guide] send in
                    await send(.setGuideStates(guide))
                    // 노티피케이션 권한 요청
                    _ = try await notification.requestPermission()
                    // 아이클라우드 동기화 요청
                    await send(.openRequestIcloudSyncSheet)
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
                    /// 현재 아이클라우드를 켜려고 시도한다.
                    let iCloudStatusTypeDTO = await analyzeAPIClients.setICloudAccountState(true)
                    switch iCloudStatusTypeDTO {
                    case .startICloudSync:
                        await analyzeAPIClients.setAutomaticSync(true)
                    default:
                        await send(.openFailedIcloudSyncSheet)
                    }
                }
            case .alert: return .none
            case .openRequestIcloudSyncSheet:
                state.alert = .requestIcloudSyncAlert
                return .none
            case .openFailedIcloudSyncSheet:
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
            PomoTimerFeature()
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
    
    static let chooseSyncOptionAlert = AlertState(
        title: {
            TextState("Do you want to delete your existing records?")
        },
        actions: {
            ButtonState(role: .none) {
                TextState("Overwrite All Existing Data in iCloud")
            }
            ButtonState(role: .cancel) {
                TextState("Delete All Existing Data")
            }
        },
        message: {
            TextState("기존 타이머 기록을 덮어쓰시겠습니까?")
        }
    )
}
