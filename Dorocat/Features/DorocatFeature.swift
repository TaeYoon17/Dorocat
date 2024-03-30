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
    enum PageType:Hashable,Equatable{
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
        var anylzeState = AnalyzeFeature.State()
        var timerState = TimerFeature.State()
        var settingState = SettingFeature.State()
    }
    enum Action:Equatable{
        case pageMove(PageType)
        case setAppState(AppStateType)
        case timer(TimerFeature.Action)
        case analyze(AnalyzeFeature.Action)
        case setting(SettingFeature.Action)
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .pageMove(let type):
                state.pageSelection = type
                return .none
            case .timer:return .none
            case .analyze:return .none
            case .setting: return .none
            case .setAppState(let appState):
                state.appState = appState
                return .run{ send in
                    await send(.timer(.setAppState(appState)))
                }
            }
        }
        Scope(state: \.timerState, action: /DorocatFeature.Action.timer) {
            TimerFeature()
        }
        Scope(state: \.settingState,action: /DorocatFeature.Action.setting){
            SettingFeature()
        }
        Scope(state: \.anylzeState,action: /DorocatFeature.Action.analyze){
            AnalyzeFeature()
        }
    }
}
