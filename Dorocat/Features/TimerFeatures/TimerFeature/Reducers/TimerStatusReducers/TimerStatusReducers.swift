//
//  TimerStatusReducers.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    // 앱의 상태가 바뀐 뒤 타이머 구성
    func setTimerStatus(state:inout TimerFeature.State,status:TimerFeatureStatus,count:Int? = nil,startDate:Date? = nil) -> Effect<TimerFeature.Action>{
        state.timerStatus = status
        return Effect.merge(StatusReducers.makeAllReducers(cancelID: CancelID.timer,
                                                           state: &state,
                                                           status: status,
                                                           count: count,
                                                           startDate: startDate))
    }
}

protocol TimerStatusProtocol{
    var cancelID: TimerFeature.CancelID { get }
    func makeReducer(state: inout TimerFeature.State,
                     status:TimerFeatureStatus,
                     count:Int?,
                     startDate:Date?) -> Effect<TimerFeature.Action>
    func setStandBy(state:inout TimerFeature.State,count:Int?,startDate:Date?)-> Effect<TimerFeature.Action>
    func setFocus(state:inout TimerFeature.State,count:Int?,startDate:Date?)-> Effect<TimerFeature.Action>
    func setPause(state:inout TimerFeature.State,count:Int?,startDate:Date?)-> Effect<TimerFeature.Action>
    func setSleep(state:inout TimerFeature.State,sleepStatus: SleepStatus,count:Int?,startDate:Date?)-> Effect<TimerFeature.Action>
    func setBreakStandBy(state:inout TimerFeature.State,count:Int?,startDate:Date?)-> Effect<TimerFeature.Action>
    func setBreakTime(state:inout TimerFeature.State,count:Int?,startDate:Date?)-> Effect<TimerFeature.Action>
    func setCompleted(state:inout TimerFeature.State,count:Int?,startDate:Date?)-> Effect<TimerFeature.Action>
}
extension TimerStatusProtocol{
    func makeReducer(state: inout TimerFeature.State,
                     status:TimerFeatureStatus,
                     count:Int?,
                     startDate:Date?) -> Effect<TimerFeature.Action>{
        switch status {
        case .standBy:
            return setStandBy(state: &state, count: count, startDate: startDate)
        case .focus:
            return setFocus(state: &state, count: count, startDate: startDate)
        case .pause:
            return setPause(state: &state, count: count, startDate: startDate)
        case .sleep(let sleepStatus):
            return setSleep(state: &state,sleepStatus: sleepStatus,count: count, startDate: startDate)
        case .breakStandBy:
            return setBreakStandBy(state: &state, count: count, startDate: startDate)
        case .breakTime:
            return setBreakTime(state: &state, count: count, startDate: startDate)
        case .completed:
            return setCompleted(state: &state, count: count, startDate: startDate)
        }
    }
}
extension TimerFeature{
    enum StatusReducers:CaseIterable{
        case liveActivity, status, analyze
        private func myReducer(cancelID: TimerFeature.CancelID) -> TimerStatusProtocol{
            switch self{
            case .liveActivity: LiveActivityReducer(cancelID: cancelID)
            case .status: StatusReducer(cancelID: cancelID)
            case .analyze: AnalyzeReducer(cancelID: cancelID)
            }
        }
        static func makeAllReducers(cancelID: TimerFeature.CancelID,
                                    state: inout TimerFeature.State,
                                    status:TimerFeatureStatus,
                                    count:Int?,
                                    startDate:Date?) -> [Effect<TimerFeature.Action>]{
            Self.allCases.map { reducer in
                reducer.myReducer(cancelID: cancelID)
                    .makeReducer(state: &state, status: status, count: count, startDate: startDate)
            }
        }
    }
}
