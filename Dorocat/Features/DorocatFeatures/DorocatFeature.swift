//
//  DorocatFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DorocatFeature{
    enum Action:Equatable{
        case pageMove(PageType)
        case setAppState(AppStateType)
        case setProUser(Bool)
        case launchAction
        case initialAction
        case onBoardingTapped
        case onBoardingWillTap
        
        case timer(TimerFeature.Action)
        case analyze(AnalyzeFeature.Action)
        case setting(SettingFeature.Action)
        case setGuideStates(Guides)
        case setActivityAction(prev:TimerActivityType,next:TimerActivityType)
    }
    @Dependency(\.guideDefaults) var guideDefaults
    @Dependency(\.haptic) var haptic
    @Dependency(\.initial) var initial
    @Dependency(\.pomoNotification) var notification
    @Dependency(\.pomoSession) var session
    @Dependency(\.pomoLiveActivity) var liveActivity
    @Dependency(\.pomoDefaults) var pomoDefaults
    @Dependency(\.timer.background) var timerBackground
    @Dependency(\.store) var store
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .pageMove(let type): return pageMoveReducer(state: &state, type: type)
            case .setAppState(let appState):
                state.appState = appState
                return .run{ send in
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
                return .run{[guide] send in
                    await send(.setGuideStates(guide))
                }
            case .onBoardingWillTap:
                return .run { send in
                    await haptic.impact(style: .soft)
                }
            case .initialAction:
                return .run{ send in
                    await haptic.setEnable(true)
                    await notification.setEnable(true)

                }
            case .setActivityAction(let prev, let next):
                return timerActivityReducer(state: &state, prev: prev, next: next)
            }
        }
        Scope(state: \.anylzeState,action: /DorocatFeature.Action.analyze){
            AnalyzeFeature()
        }
        Scope(state: \.timerState, action: /DorocatFeature.Action.timer) {
            TimerFeature()
        }
        Scope(state: \.settingState,action: /DorocatFeature.Action.setting){
            SettingFeature()
        }
    }
}
