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
        var anylzeState = AnalyzeFeature.State()
        var timerState = TimerFeature.State()
        var settingState = SettingFeature.State()
    }
    enum Action:Equatable{
        case pageMove(PageType)
        case setAppState(AppStateType)
        case initAction
        case onBoardingTapped
        case timer(TimerFeature.Action)
        case analyze(AnalyzeFeature.Action)
        case setting(SettingFeature.Action)
        case setGuideStates(Guides)
    }
    @Dependency(\.guideDefaults) var guideDefaults
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .pageMove(let type):
                state.pageSelection = type
                switch type{
                case .analyze:
                    if !state.guideState.goLeft{
                        state.guideState.goLeft = true
                        return .run{[guide = state.guideState] send in
                            await send(.setGuideStates(guide))
                        }
                    }else{
                        return .none
                    }
                case .timer: return .none
                case .setting:
                    if !state.guideState.goRight{
                        state.guideState.goRight = true
                        return .run{[guide = state.guideState] send in
                            await send(.setGuideStates(guide))
                        }
                    }else{
                        return .none
                    }
                }
            case .setAppState(let appState):
                state.appState = appState
                return .run{ send in
                    await send(.timer(.setAppState(appState)))
                }
            case .initAction:
                if !state.isAppLaunched{
                    state.isAppLaunched = true
                    state.guideState.onBoarding = true
                    return .run{ send in
                        let guides = await self.guideDefaults.get()
                        await send(.setGuideStates(guides))
                        await send(.timer(.setGuideState(guides)))
                    }
                }else{
                    return .none
                }
            case .timer(.setGuideState(let guide)):
                guard guide != state.guideState else {return .none}
                state.guideState = guide
                return .run{[guides = state.guideState] send in
                    await self.guideDefaults.set(guide: guides)
                }
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
