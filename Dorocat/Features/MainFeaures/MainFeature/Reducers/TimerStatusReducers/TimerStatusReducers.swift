//
//  TimerStatusReducers.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture
extension MainFeature{
    // 앱의 상태가 바뀐 뒤 타이머 구성
    func setTimerStatus(state:inout MainFeature.State,
                        status:TimerStatus,
                        count:Int? = nil,
                        startDate:Date? = nil) -> Effect<MainFeature.Action>{
        state.timerProgressEntity.status = status
        return Effect.merge(StatusReducers.makeAllReducers(cancelID: CancelID.timer,
                                                           state: &state,
                                                           status: status,
                                                           count: count,
                                                           startDate: startDate))
    }
}

protocol TimerStatusProtocol{
    var cancelID: MainFeature.CancelID { get }
    func makeReducer(state: inout MainFeature.State,
                     status:TimerStatus,
                     count:Int?,
                     startDate:Date?) -> Effect<MainFeature.Action>
    
    func setStandBy(state:inout MainFeature.State,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    func setFocus(state:inout MainFeature.State,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    func setPause(state:inout MainFeature.State,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    func setSleep(state:inout MainFeature.State,sleepStatus: SleepStatus,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    func setBreakTime(state:inout MainFeature.State,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    func setCompleted(state:inout MainFeature.State,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    func setBreakStandBy(state:inout MainFeature.State,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    func setFocusStandBy(state:inout MainFeature.State,count:Int?,startDate:Date?)-> Effect<MainFeature.Action>
    
}
extension TimerStatusProtocol{
    func makeReducer(state: inout MainFeature.State,
                     status:TimerStatus,
                     count:Int?,
                     startDate:Date?) -> Effect<MainFeature.Action>{
        switch status {
        case .standBy:
            return setStandBy(state: &state, count: count, startDate: startDate)
        case .focus:
            return setFocus(state: &state, count: count, startDate: startDate)
        case .pause:
            return setPause(state: &state, count: count, startDate: startDate)
        case .sleep(let sleepStatus):
            return setSleep(state: &state,sleepStatus: sleepStatus,count: count, startDate: startDate)
        case .breakTime:
            return setBreakTime(state: &state, count: count, startDate: startDate)
        case .completed: return setCompleted(state: &state, count: count, startDate: startDate)
        case .breakStandBy: return setBreakStandBy(state: &state, count: count, startDate: startDate)
        case .focusStandBy: return setFocusStandBy(state: &state, count: count, startDate: startDate)
        }
    }
}
extension MainFeature{
    enum StatusReducers:CaseIterable{
        case liveActivity, status, analyze
        private func myReducer(cancelID: MainFeature.CancelID) -> TimerStatusProtocol{
            switch self{
            case .liveActivity: LiveActivityReducer(cancelID: cancelID)
            case .status: StatusReducer(cancelID: cancelID)
            case .analyze: AnalyzeReducer(cancelID: cancelID)
            }
        }
        static func makeAllReducers(cancelID: MainFeature.CancelID,
                                    state: inout MainFeature.State,
                                    status:TimerStatus,
                                    count:Int?,
                                    startDate:Date?) -> [Effect<MainFeature.Action>]{
            Self.allCases.map { reducer in
                reducer.myReducer(cancelID: cancelID)
                    .makeReducer(state: &state, status: status, count: count, startDate: startDate)
            }
        }
    }
}
