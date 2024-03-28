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
        state.timerStatus = status
        switch status{
        case .standBy:
            state.count = state.timerInformation.timeSeconds
            return .none
        case .running:
            return .run { send in
                while true{
                    try await Task.sleep(for: .seconds(1))
                    await send(.timerTick)
                }
            }.cancellable(id: CancelID.timer)
        case .pause: return .cancel(id: CancelID.timer)
        case .completed:
            // 여기에 DB 데이터 추가..?
            return .cancel(id: CancelID.timer)
        case .shortBreak:
            state.count = state.timerInformation.shortBreak
            return .run{ send in
                    while true{
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }
        case .longBreak:
            state.count = state.timerInformation.longBreak
            return .run{ send in
                while true{
                    try await Task.sleep(for: .seconds(1))
                    await send(.timerTick)
                }
            }
        }
    }
}
extension TimerFeature{
    func timerTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        state.timerInformation.isPomoMode ? pomoTick(state: &state) : defaultTick(state: &state)
    }
    private func pomoTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        let num = state.count - 1
        let cycle = state.cycle
        if num < 0{
            state.count = num
            return .none
        }else{
            switch state.timerStatus{
            case .running: return Effect.concatenate([
                .cancel(id: CancelID.timer),
                cycle <= 0 ? // trigger 역할을 수행한다.
                    .run{ send in
                        await send(.setStatus(.longBreak))
                    }
                : .run{ send in
                    await send(.setStatus(.shortBreak))
                    }
                ])
            case .longBreak: return .none
            case .shortBreak: return .none
            default: return .cancel(id: CancelID.timer)
            }
        }
//        switch state.timerStatus{
//        case .running:
//            if num < 0{
//                // 공통으로 기존의 Timer는 Cancellable 해야함...
//                if cycle <= 0 { // 사이클이 모두 끝남... Long Break으로 이동...
//                    return Effect.concatenate([
//                        .cancel(id: CancelID.timer),
//                        .run{ send in
//                            await send(.setStatus(.longBreak))
//                        }
//                    ])
//                }else{ // 사이클이 남아 있음... Short Break으로 이동...
//                    return Effect.concatenate([
//                        .cancel(id: CancelID.timer),
//                        .run{ send in
//                            await send(.setStatus(.shortBreak))
//                        }
//                    ])
//                }
//            }else{
//                state.count = num
//                return .none
//            }
//        case .longBreak: return .none
//        case .shortBreak: return .none
//        default: return .cancel(id: CancelID.timer)
//        }
    }
    private func defaultTick(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        guard state.timerStatus == .running else{ return .cancel(id: CancelID.timer)}
        let num = state.count - 1
        if num < 0{
            return .run{ send in
                await send(.setStatus(.completed))
            }
        }else{
            state.count = num
            return .none
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
