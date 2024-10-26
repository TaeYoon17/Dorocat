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
        let num = state.timerProgressEntity.count - 1
        if num > 0{
            state.timerProgressEntity.count = num
            return .none
        }else{
            switch state.timerProgressEntity.status{
            case .focus:
                state.timerProgressEntity.cycle += 1
                let cycleEffect:Effect<MainFeature.Action> = state.timerProgressEntity.cycle >= state.timerSettingEntity.cycle ?
                        .run{ await $0(.setStatus(.completed)) }
                    : .run{ await $0(.setStatus(.breakStandBy)) }
                return Effect.merge([.cancel(id: CancelID.timer),cycleEffect])
            case .breakTime: // breakTime 시간이 끝남...
                state.timerProgressEntity.count = state.timerSettingEntity.timeSeconds
                return Effect.merge([.cancel(id: CancelID.timer),.run { send in
                        await send(.setStatus(.focusStandBy))
                    }
                ])
            default: return .cancel(id: CancelID.timer)
            }
        }
    }
    // 기본 타이머 모드일 때 타이머에서 1초가 줄어들 때
    private func defaultTick(state: inout MainFeature.State) -> Effect<MainFeature.Action>{
        guard state.timerProgressEntity.status == .focus else{ return .cancel(id: CancelID.timer)}
        let num = state.timerProgressEntity.count - 1
        if num > 0{
            state.timerProgressEntity.count = num
            return .none
        }else{
            return .run{ send in
                await send(.setStatus(.completed))
            }
        }
    }
}
