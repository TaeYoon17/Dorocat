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
        case launchAction
        case initialAction
        case onBoardingTapped
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
                    await haptic.impact(style: .soft)
                    await send(.setGuideStates(guide))
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
