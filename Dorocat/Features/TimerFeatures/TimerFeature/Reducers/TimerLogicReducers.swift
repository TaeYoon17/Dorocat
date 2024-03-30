//
//  TimerLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    func setTimer(state:inout TimerFeature.State,status:TimerFeatureStatus) -> Effect<TimerFeature.Action>{
        switch status{
        case .standBy:
            state.cycle = 0
            state.count = state.timerInformation.timeSeconds
            return .none
        case .pomoing:
            state.count = state.timerInformation.timeSeconds
            return .run {[count = state.timerInformation.timeSeconds] send in
                await send(.setTimerRunning(count))
            }
        case .pause: return .cancel(id: CancelID.timer)
        case .completed:
            // 여기에 DB 데이터 추가..?
            return .cancel(id: CancelID.timer)
        case .shortBreak:
            return .run{[count = state.timerInformation.shortBreak] send in
                await send(.setTimerRunning(count))
            }
        case .longBreak:
            return .run{[count = state.timerInformation.longBreak] send in
                await send(.setTimerRunning(count))
            }
        }
    }
}
extension TimerFeature{
    func timerTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        return state.timerInformation.isPomoMode ? pomoTick(state: &state) : defaultTick(state: &state)
    }
    private func pomoTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        let num = state.count - 1
        if num > 0{
            state.count = num
            return .none
        }else{
            switch state.timerStatus{
            case .pomoing:
                state.cycle += 1
                // trigger 역할을 수행한다.
                let cycleEffect:Effect<TimerFeature.Action> = state.cycle >= state.timerInformation.cycle ?
                        .run{ send in
                            await send(.setStatus(.longBreak))
                        }
                    : .run{ send in
                        await send(.setStatus(.shortBreak))
                    }
                return Effect.concatenate([
                .cancel(id: CancelID.timer),
                cycleEffect
            ])
            case .longBreak:
                state.count = state.timerInformation.longBreak
                return Effect.concatenate([
                    .cancel(id: CancelID.timer),
                    .run(operation: { send in
                        await send(.setStatus(.completed))
                    })
                ])
            case .shortBreak: // shortBreak 시간이 끝남...
                state.count = state.timerInformation.shortBreak
                return Effect.concatenate([
                    .cancel(id: CancelID.timer),
                    .run { send in
                        await send(.setStatus(.pomoing))
                    }
                ])
            default: return .cancel(id: CancelID.timer)
            }
        }
    }
    private func defaultTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        guard state.timerStatus == .pomoing else{ return .cancel(id: CancelID.timer)}
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
//let num = state.count - 1
//let cycle = state.cycle
//if num < 0{
//    if cycle <= 0{
//        return .run{ send in
//            await send(.setStatus(.longBreak))
//        }
//    }else{
//        return .run{ send in
//            await send(.setStatus(.shortBreak))
//        }
//    }
//}else{
//    state.count = num
//    return .none
//}
