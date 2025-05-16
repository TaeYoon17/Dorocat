//
//  TimerStatus>Analyze.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture
extension PomoTimerFeature.StatusReducers{
    struct AnalyzeReducer:TimerStatusProtocol{
        @Dependency(\.analyzeAPIClients) var analyze
        
        var cancelID: PomoTimerFeature.CancelID
        
        func setStandBy(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> { .none }
        
        func setFocus(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> { .none }
        
        func setPause(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> { .none }
        
        func setSleep(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> { .none }
        
        func setBreakStandBy(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<PomoTimerFeature.Action> {
            let startDate = state.timerProgressEntity.startDate
            let duration = state.timerSettingEntity.timeSeconds / 60
            let session = state.timerProgressEntity.session
            return .run(priority: .medium) { send in
                try await Task.sleep(for: .seconds(0.666))
                await analyze.append(.init(createdAt: startDate, duration: duration,session: session))
            }
        }
        func setFocusStandBy(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            return .none
        }
        func setBreakTime(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> { .none }
        
        func setCompleted(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<PomoTimerFeature.Action> {
            let startDate = state.timerProgressEntity.startDate
            let duration = state.timerSettingEntity.timeSeconds / 60
            let session = state.timerProgressEntity.session
            return .run(priority: .medium) { send in
                try await Task.sleep(for: .seconds(0.666))
                await analyze.append(.init(createdAt: startDate, duration: duration,session: session))
            }
        }
    }
}
