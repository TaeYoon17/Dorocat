//
//  ViewReducers.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    func timerFieldTapped(state:inout TimerFeature.State) ->  Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .focus:
            return .run { send in
                await send(.setStatus(.pause(.focusPause)))
            }
        case .pause(.focusPause):
            return .run {[count = state.count] send in
            await send(.setStatus(.focus,isRequiredSetTimer: false))
            await send(.setTimerRunning(count))
        }
        case .standBy: // standby일때 탭하면 세팅하는 화면으로 설정한다.
            state.timerSetting = TimerSettingFeature.State()
            return .run {[info = state.timerInformation] send in
                print(info)
                await send(.timerSetting(.presented(.setDefaultValues(info))))
            }
        default: return .none
        }
    }

    func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .standBy:
            guard state.count != 0 else {return .none}
            return .run { send in
                await send(.setStatus(.focus))
            }
        case .focus: return .run { send in
            await send(.setStatus(.pause(.focusPause)))
        }
        case .pause(.focusPause):
            return .run {[count = state.count] send in
            await send(.setStatus(.focus,isRequiredSetTimer: false))
            await send(.setTimerRunning(count))
        }
        case .completed: return .run{ send in
            await send(.setStatus(.standBy))
        }
        default: return .none
        }
    }

    func circleTimerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .focus:
            return .run { send in
                await send(.setStatus(.pause(.focusPause)))
            }
        default: return .none
        }
    }

    func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .shortBreak,.longBreak,.pause: return .run{ send in
            await send(.setStatus(.standBy))
        }
        default: return .none
        }
    }
    func completeTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .completed: return .run{ send in
            await send(.setStatus(.standBy))
        }
        default: return .none
        }
    }
}
