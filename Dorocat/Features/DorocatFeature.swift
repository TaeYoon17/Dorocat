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
    @ObservableState struct State: Equatable{
        var pageSelection: PageType = .timer
        var appState = AppStateType.active
        var guideState = Guides()
        var isAppLaunched = false
        var showPageIndicator = true
        var anylzeState = AnalyzeFeature.State()
        var timerState = TimerFeature.State()
        var settingState = SettingFeature.State()
    }
    enum Action:Equatable{
        case pageMove(PageType)
        case setAppState(AppStateType)
        case launchAction
        case onBoardingTapped
        case timer(TimerFeature.Action)
        case analyze(AnalyzeFeature.Action)
        case setting(SettingFeature.Action)
        case setGuideStates(Guides)
        case initialAction
    }
    @Dependency(\.guideDefaults) var guideDefaults
    @Dependency(\.haptic) var haptic
    @Dependency(\.initial) var initial
    @Dependency(\.pomoNotification) var notification
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
                    }))
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
                case .standBy: state.showPageIndicator = true
                default: state.showPageIndicator = false
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
                }
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
