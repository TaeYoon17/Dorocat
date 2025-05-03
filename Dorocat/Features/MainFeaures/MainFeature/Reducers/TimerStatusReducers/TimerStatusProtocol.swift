//
//  TimerStatusProtocol.swift
//  Dorocat
//
//  Created by Greem on 4/14/25.
//

import Foundation
import ComposableArchitecture

protocol TimerStatusProtocol {
    var cancelID: MainFeature.CancelID { get }
    func makeReducer(state: inout MainFeature.State,
                     status: TimerStatus,
                     count: Int?,
                     startDate: Date?) -> Effect<MainFeature.Action>
    /// StandBy 상태입니다.
    func setStandBy(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
    /// Focus 모드 상태입니다.
    func setFocus(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
    /// Pause 모드 상태입니다.
    func setPause(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
    /// Sleep 모드 상태입니다.
    func setSleep(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
    /// 쉬는 시간 상태입니다.
    func setBreakTime(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
    /// 완료 시간 상태입니다.
    func setCompleted(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
    /// 쉬는 시간 대기 상태입니다.
    func setBreakStandBy(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
    /// 집중 모드 대기 상태입니다.
    func setFocusStandBy(state:inout MainFeature.State, count:Int?, startDate:Date?) -> Effect<MainFeature.Action>
}

extension TimerStatusProtocol {
    func makeReducer(
        state: inout MainFeature.State,
        status:TimerStatus,
        count:Int?,
        startDate:Date?
    ) -> Effect<MainFeature.Action> {
        switch status {
        case .standBy:
            return setStandBy(state: &state, count: count, startDate: startDate)
        case .focus:
            return setFocus(state: &state, count: count, startDate: startDate)
        case .pause:
            return setPause(state: &state, count: count, startDate: startDate)
        case .breakSleep, .focusSleep:
            return setSleep(state: &state,count: count, startDate: startDate)
        case .breakTime:
            return setBreakTime(state: &state, count: count, startDate: startDate)
        case .completed: return setCompleted(state: &state, count: count, startDate: startDate)
        case .breakStandBy: return setBreakStandBy(state: &state, count: count, startDate: startDate)
        case .focusStandBy: return setFocusStandBy(state: &state, count: count, startDate: startDate)
        }
    }
}
