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
    func setTimerStatus(state:inout TimerFeature.State,status:TimerFeatureStatus,count:Int? = nil) -> Effect<TimerFeature.Action>{
        state.timerStatus = status
        let runningEffect: Effect<Action> = .run{[count = state.count] send in
            await send(.setTimerRunning(count))
       }
        switch status{
        case .standBy:
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            state.cycle = 0
            state.count = state.timerInformation.timeSeconds
            return .none
        case .focus:
            let count = count ?? state.timerInformation.timeSeconds
            state.count = count
            return .run {send in
                await send(.setTimerRunning(count))
            }
        case .breakTime:
            let count = count ?? state.timerInformation.breakTime
            state.count = count
            return .run { send in
                await send(.setTimerRunning(count))
            }
        case .pause:
            if let count{ fatalError("여기에 존재하면 안된다!!")}
            return .cancel(id: CancelID.timer)
        case .completed,.breakStandBy:
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            let startDate = state.startDate
            let duration = state.timerInformation.timeSeconds / 60
            if status == .breakStandBy{
                state.count = state.timerInformation.breakTime
            }
            return Effect.concatenate(.cancel(id: CancelID.timer),
                                      .run(operation: {send in
                await analyzeAPI.append(.init(createdAt: startDate, duration: duration))
            }))
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
                let cycleEffect:Effect<TimerFeature.Action> = state.cycle >= state.timerInformation.cycle ?
                        .run{ await $0(.setStatus(.completed)) }
                    : .run{ await $0(.setStatus(.breakStandBy)) }
                return Effect.merge([.cancel(id: CancelID.timer),cycleEffect])
            case .breakTime: // breakTime 시간이 끝남...
                state.count = state.timerInformation.timeSeconds
                return Effect.merge([.cancel(id: CancelID.timer),.run { send in
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
