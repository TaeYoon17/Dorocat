//
//  TimerStatus>Status.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature.StatusReducers{
    struct StatusReducer: TimerStatusProtocol{
        var cancelID: TimerFeature.CancelID
        func setStandBy(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            state.cycle = 0
            state.count = state.timerInformation.timeSeconds
            return .cancel(id: cancelID)
        }
        
        func setFocus(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            if let startDate{ state.startDate = startDate }
            let count = count ?? state.timerInformation.timeSeconds
            state.count = count
            return .concatenate(.cancel(id: cancelID),
                                .run(priority: .high)  { send in
                                    await send(.setTimerRunning(count))
                                })
        }
        
        func setPause(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            return .cancel(id: cancelID)
        }
        
        func setSleep(state: inout TimerFeature.State, sleepStatus: SleepStatus, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            if let count { fatalError("여기에 존재하면 안된다!!")}
            print("Sleep 모드로 타이머 전환")
            return .cancel(id: cancelID)
        }
        func setBreakTime(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            if let startDate{state.startDate = startDate}
            let count = count ?? state.timerInformation.breakTime
            state.count = count
            return .concatenate(.cancel(id: cancelID),.run(priority: .high) { send in
                await send(.setTimerRunning(count))
            })
        }
        func setBreakStandBy(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            state.count = state.timerInformation.breakTime
            return .concatenate(.cancel(id: cancelID))
        }
        
        func setCompleted(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            return .concatenate(.cancel(id: cancelID))
        }
    }
}
