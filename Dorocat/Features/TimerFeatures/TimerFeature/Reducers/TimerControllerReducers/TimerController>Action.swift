//
//  TimerController>Action.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature.ControllerReducers{
    struct ActionReducer: TimerControllerProtocol{
        typealias Action = TimerFeature.Action
        func timerFieldTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .standBy: // standby일때 탭하면 세팅하는 화면으로 설정한다.
                state.timerSetting = TimerSettingFeature.State()
                return .run {[info = state.timerInformation] send in
                    await send(.timerSetting(.presented(.setDefaultValues(info))))
                }
            default: return .none
            }
        }
        func catTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            return .none
        }
        
        func resetTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .breakTime,.pause: return .run { send in
                await send(.setStatus(.standBy, count: nil))
                }
            default: return .none
            }
        }
        
        func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .standBy:
                guard state.count != 0 else {return .none}
                return .run { send in
                    await send(.setStatus(.focus,startDate: Date()))
                }
            case .focus: return .run { send in
                await send(.setStatus(.pause))
            }
            case .pause:
                return .run {[count = state.count] send in
                    await send(.setStatus(.focus,count: count))
                }
            case .completed: return .run{ send in
                await send(.setStatus(.standBy))
            }
            case .breakStandBy:
                return .run { send in
                    await send(.setStatus(.breakTime,startDate: Date()))
                }
            case .breakTime: return .run { await $0(.setStatus(.standBy)) }
            case .sleep: return .none
            }
        }
        func triggerWillTap(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .none
        }
    }
}
