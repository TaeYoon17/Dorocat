//
//  TimerLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    func timerTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        return state.timerInformation.isPomoMode ? pomoTick(state: &state) : defaultTick(state: &state)
    }
    // 포모도로 모드일 때 and 타이머에서 1초가 줄어들 때
    private func pomoTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        let num = state.count - 1
        if num > 0{
            state.count = num
            return .none
        }else{
            switch state.timerStatus{
            case .focus:
                state.cycle += 1
                let cycleEffect:Effect<TimerFeature.Action> = state.cycle >= state.timerInformation.cycle ?
                        .run{ await $0(.setStatus(.completed)) }
                    : .run{ await $0(.setStatus(.breakStandBy)) }
                return Effect.merge([.cancel(id: CancelID.timer),cycleEffect])
            case .breakTime: // breakTime 시간이 끝남...
                state.count = state.timerInformation.timeSeconds
                return Effect.merge([.cancel(id: CancelID.timer),.run { send in
                        await send(.setStatus(.focusStandBy))
                    }
                ])
            default: return .cancel(id: CancelID.timer)
            }
        }
    }
    // 기본 타이머 모드일 때 타이머에서 1초가 줄어들 때
    private func defaultTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        guard state.timerStatus == .focus else{ return .cancel(id: CancelID.timer)}
        let num = state.count - 1
        if num > 0{
            state.count = num
            return .none
        }else{
            return .run{ send in
                await send(.setStatus(.completed))
            }
        }
    }
}
