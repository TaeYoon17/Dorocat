//
//  TimerLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    // 앱의 상태가 바뀐 뒤 타이머 구성
    func setTimer(state:inout TimerFeature.State,status:TimerFeatureStatus) -> Effect<TimerFeature.Action>{
        switch status{
        case .standBy:
            state.cycle = 0
            state.count = state.timerInformation.timeSeconds
            return .none
        case .focus:
            state.count = state.timerInformation.timeSeconds
            return .run {[count = state.timerInformation.timeSeconds] send in
                await send(.setTimerRunning(count))
            }
        case .pause: return .cancel(id: CancelID.timer)
        case .completed:
            // 여기에 DB 데이터 추가..?
            let startDate = state.startDate
            let duration = state.timerInformation.timeSeconds
            return Effect.concatenate(.cancel(id: CancelID.timer),.run(operation: {send in
                await analyzeAPI.append(.init(createdAt: startDate, duration: duration))
            }))
        case .breakTime:
            return .run{[count = state.timerInformation.breakTime] send in
                await send(.setTimerRunning(count))
           }
        }
    }
}
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
                // trigger 역할을 수행한다.
                let cycleEffect:Effect<TimerFeature.Action> = state.cycle >= state.timerInformation.cycle ?
                        .run{ send in
                            await send(.setStatus(.completed))
                        }
                    : .run{ send in
                        await send(.setStatus(.breakTime))
                    }
                return Effect.concatenate([
                .cancel(id: CancelID.timer),
                cycleEffect
            ])
            case .breakTime: // breakTime 시간이 끝남...
                state.count = state.timerInformation.breakTime
                return Effect.concatenate([
                    .cancel(id: CancelID.timer),
                    .run { send in
                        await send(.setStatus(.focus))
                    }
                ])
            default: return .cancel(id: CancelID.timer)
            }
        }
    }
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
