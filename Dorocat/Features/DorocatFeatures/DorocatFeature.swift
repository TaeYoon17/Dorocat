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
    enum PageType:String,Hashable,Equatable,CaseIterable,Identifiable{
        var id:String{ self.rawValue }
        case analyze
        case timer
        case setting
    }
    enum AppStateType:Hashable,Equatable{
        case inActive,active,background
    }
    
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
    @Dependency(\.timeBackground) var timeBackground
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .pageMove(let type):
                state.pageSelection = type
                let softImpact:Effect<Action> = .run{ send in await haptic.impact(style: .soft,intensity: 0.7)}
                switch type{
                case .analyze:
                    if !state.guideState.goLeft{
                        state.guideState.goLeft = true
                        return .run{[guide = state.guideState] send in
                            await send(.setGuideStates(guide))
                        }.merge(with: softImpact)
                    }else{
                        return softImpact
                    }
                case .timer: return .run{send in await haptic.impact(style: .rigid,intensity: 0.7)}
                case .setting:
                    if !state.guideState.goRight{
                        state.guideState.goRight = true
                        return Effect.merge(.run{[guide = state.guideState] send in
                            await send(.setGuideStates(guide))
                        },softImpact)
                    }else{
                        return softImpact
                    }
                }
            case .setAppState(let appState):
                state.appState = appState
                return .run{ send in
                    await send(.timer(.setAppState(appState)))
                    await send(.setting(.setAppState(appState)))
                }
            case .launchAction:
                if !state.isAppLaunched{
                    state.isAppLaunched = true
                    state.guideState.onBoarding = true
                    return Effect.merge(.run{ send in
                        let guides = await self.guideDefaults.get()
                        await send(.setGuideStates(guides))
                        await send(.timer(.setGuideState(guides)))
                    },.run(operation: { send in
                        if await !initial.isUsed{
                            await initial.offInitial()
                            await send(.initialAction)
                        }
                    }),.run{ send in
                        try! await session.initAction()
                    })
                }else{
                    return .none
                }
            case .timer(.setGuideState(let guide)):
                guard guide != state.guideState else {return .none}
                state.guideState = guide
                return .run{[guides = state.guideState] send in
                    await self.guideDefaults.set(guide: guides)
                }
            case .timer(.setStatus(let status,_,_)):
                switch status{
                case .focus,.breakTime:
                    state.showPageIndicator = false
                default:
                    state.showPageIndicator = true
                }
                return .none
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
            case .timer: return .none
            case .analyze:return .none
            case .setting: return .none
            case .initialAction:
                return .run{ send in
                    await haptic.setEnable(true)
                    await notification.setEnable(true)
                }
            case .setActivityAction(let prev, let next):
                print("Feature로 전달은 되었다")
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
