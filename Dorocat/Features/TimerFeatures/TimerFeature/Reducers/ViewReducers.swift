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
        var effects:[Effect<TimerFeature.Action>] = []
        if !state.guideInformation.onBoarding{
            state.guideInformation.onBoarding = true
            effects.append(.run(operation: {[guides = state.guideInformation] send in
                await guideDefaults.set(guide: guides)
            }))
        }
        switch state.timerStatus{
        case .focus:
            effects.append(.run { send in
                await send(.setStatus(.pause(.focusPause)))
            })
        case .pause(.focusPause):
            effects.append(.run {[count = state.count] send in
                await send(.setStatus(.focus,isRequiredSetTimer: false))
                await send(.setTimerRunning(count))}
        )
        case .standBy: // standby일때 탭하면 세팅하는 화면으로 설정한다.
            state.timerSetting = TimerSettingFeature.State()
                effects.append( .run {[info = state.timerInformation] send in
                    await send(.timerSetting(.presented(.setDefaultValues(info))))
                }
            )
        default: break
        }
        return Effect.concatenate(effects)
    }
    func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .standBy:
            guard state.count != 0 else {return .none}
            state.startDate = Date()
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
        case .breakTime,.pause: return .run{ send in
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
    func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        catTapped(state: &state)
    }
}
