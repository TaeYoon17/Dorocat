//
//  TimerStatus>Analyze.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture
extension MainFeature.StatusReducers{
    struct AnalyzeReducer:TimerStatusProtocol{
        @Dependency(\.analyzeAPIClients) var analyze
        
        var cancelID: MainFeature.CancelID
        
        func setStandBy(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> { .none }
        
        func setFocus(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> { .none }
        
        func setPause(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> { .none }
        
        func setSleep(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> { .none }
        
        func setBreakStandBy(state: inout MainFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<MainFeature.Action> {
            let startDate = state.timerProgressEntity.startDate
            let duration = state.timerSettingEntity.timeSeconds / 60
            let session = state.timerProgressEntity.session
            return .run(priority: .medium) { send in
                try await Task.sleep(for: .seconds(0.666))
                await analyze.append(.init(createdAt: startDate, duration: duration,session: session))
            }
        }
        func setFocusStandBy(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> {
            return .none
        }
        func setBreakTime(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> { .none }
        
        func setCompleted(state: inout MainFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<MainFeature.Action> {
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
