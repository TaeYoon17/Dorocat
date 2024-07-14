//
//  TimerStatus>Analyze.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature.StatusReducers{
    struct AnalyzeReducer:TimerStatusProtocol{
        
        
        @Dependency(\.analyzeAPIClients) var analyze
        var cancelID: TimerFeature.CancelID
        
        func setStandBy(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> { .none }
        
        func setFocus(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> { .none }
        
        func setPause(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> { .none }
        
        func setSleep(state: inout TimerFeature.State, sleepStatus: SleepStatus, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> { .none }
        
        func setBreakStandBy(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            let startDate = state.startDate
            let duration = state.timerInformation.timeSeconds / 60
            let session = state.selectedSession
            return .run(priority: .medium) { send in
                await analyze.append(.init(createdAt: startDate, duration: duration,session: session))
            }
        }
        func setFocusStandBy(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            return .none
        }
        func setBreakTime(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> { .none }
        
        func setCompleted(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            let startDate = state.startDate
            let duration = state.timerInformation.timeSeconds / 60
            let session = state.selectedSession
            return .run(priority: .medium) { send in
                await analyze.append(.init(createdAt: startDate, duration: duration,session: session))
            }
        }
    }
}
