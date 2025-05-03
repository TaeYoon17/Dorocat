//
//  TimerLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture
extension MainFeature{
    func timerTick(state: inout MainFeature.State) -> Effect<MainFeature.Action>{
        return state.timerSettingEntity.isPomoMode ? pomoTick(state: &state) : defaultTick(state: &state)
    }
    // 포모도로 모드일 때 and 타이머에서 1초가 줄어들 때
    private func pomoTick(state: inout MainFeature.State) -> Effect<MainFeature.Action>{
        return timerCompletedAction(state: &state) { state in
            switch state.timerProgressEntity.status{
            case .focus:
                state.timerProgressEntity.cycle += 1
                let isCompletedCycle = state.timerProgressEntity.cycle >= state.timerSettingEntity.cycle
                
                return Effect.merge([.cancel(id: CancelID.timer), .run {
                    await $0(.setStatus( isCompletedCycle ? TimerStatus.completed : TimerStatus.breakStandBy ))
                }])
            case .breakTime: // breakTime 시간이 끝남...
                state.timerProgressEntity.count = state.timerSettingEntity.timeSeconds
                return Effect.merge([ .cancel(id: CancelID.timer), .run {
                    await $0(.setStatus(.focusStandBy))
                }])
            default: return .cancel(id: CancelID.timer)
            }
        }
    }
    // 기본 타이머 모드일 때 타이머에서 1초가 줄어들 때
    private func defaultTick(state: inout MainFeature.State) -> Effect<MainFeature.Action>{
        guard state.timerProgressEntity.status == .focus else{ return .cancel(id: CancelID.timer) }
        return timerCompletedAction(state: &state) { state in
            return .run{ send in await send(.setStatus(.completed)) }
        }
    }
    private func timerCompletedAction(state: inout MainFeature.State,
                                      action: @escaping (inout MainFeature.State)-> Effect<MainFeature.Action>) -> Effect<MainFeature.Action> {
        let num = state.timerProgressEntity.count - 1
        if num > 0{
            state.timerProgressEntity.count = num
            return .none
        }else{
            return action(&state)
        }
    }
}
