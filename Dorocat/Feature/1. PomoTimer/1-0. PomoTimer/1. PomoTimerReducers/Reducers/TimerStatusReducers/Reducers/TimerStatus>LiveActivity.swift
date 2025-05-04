//
//  TimerStatus>LiveActivity.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture

extension PomoTimerFeature.StatusReducers{
    struct LiveActivityReducer: TimerStatusProtocol{
        func setSleep(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> { .none }
        
        
        @Dependency(\.pomoLiveActivity) var liveActivity
        var cancelID: PomoTimerFeature.CancelID
        func setStandBy(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            return .run { send in
                await liveActivity.removeActivity()
            }
        }
        
        func setFocus(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            let count = count ?? state.timerSettingEntity.timeSeconds
            let focusTotalTime = state.timerSettingEntity.timeSeconds
            let session = state.timerProgressEntity.session
            return .run {[cat = state.catType] send in
                await liveActivity.removeActivity()
                await liveActivity.addActivity(type: .focusSleep,item: session, cat: cat, restCount: count, totalCount: focusTotalTime)
            }
        }
        
        func setPause(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            return .run { send in await liveActivity.removeActivity() }
        }
        
        
        func setBreakStandBy(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            return .run { send in await liveActivity.removeActivity() }
        }
        func setFocusStandBy(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            return .run{ send in await liveActivity.removeActivity() }
        }
        
        func setBreakTime(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            let count = count ?? state.timerSettingEntity.breakTime
            let breakTotalTime = state.timerSettingEntity.breakTime
            return .run {[item = state.timerProgressEntity.session, cat = state.catType]send in
                await liveActivity.removeActivity()
                await liveActivity.addActivity(type:.breakSleep,item:item, cat: cat,restCount: count,totalCount: breakTotalTime)
            }
        }
        
        func setCompleted(state: inout PomoTimerFeature.State, count: Int?, startDate: Date?) -> Effect<PomoTimerFeature.Action> {
            return .run { send in await liveActivity.removeActivity() }
        }
    }
}
