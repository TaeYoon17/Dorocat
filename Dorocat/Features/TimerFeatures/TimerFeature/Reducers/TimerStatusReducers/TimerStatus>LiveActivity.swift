//
//  TimerStatus>LiveActivity.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature.StatusReducers{
    struct LiveActivityReducer: TimerStatusProtocol{
        @Dependency(\.pomoLiveActivity) var liveActivity
        var cancelID: TimerFeature.CancelID
        func setStandBy(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            return .run { send in
                await liveActivity.removeActivity()
            }
        }
        
        func setFocus(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            let count = count ?? state.timerInformation.timeSeconds
            let focusTotalTime = state.timerInformation.timeSeconds
            return .run { send in
                await liveActivity.removeActivity()
                await liveActivity.addActivity(restCount: count, totalCount: focusTotalTime)
            }
        }
        
        func setPause(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            return .run { send in await liveActivity.removeActivity() }
        }
        
        func setSleep(state: inout TimerFeature.State,sleepStatus:SleepStatus ,count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            return .none
        }
        
        func setBreakStandBy(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            return .run { send in await liveActivity.removeActivity() }
        }
        
        func setBreakTime(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            let count = count ?? state.timerInformation.breakTime
            let breakTotalTime = state.timerInformation.breakTime
            return .run {send in
                await liveActivity.removeActivity()
                await liveActivity.addActivity(restCount: count,totalCount: breakTotalTime)
            }
        }
        
        func setCompleted(state: inout TimerFeature.State, count: Int?, startDate: Date?) -> Effect<TimerFeature.Action> {
            return .run { send in await liveActivity.removeActivity() }
        }
    }
}
