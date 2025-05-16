//
//  TimerStatusReducers.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture
extension PomoTimerFeature{
    // 앱의 상태가 바뀐 뒤 타이머 구성
    func setTimerStatus(
        state:inout PomoTimerFeature.State,
        status:TimerStatus,
        count:Int? = nil,
        startDate:Date? = nil
    ) -> Effect<PomoTimerFeature.Action> {
        state.timerProgressEntity.status = status
        return Effect.merge(
            StatusReducers.makeAllReducers(
                cancelID: CancelID.timer,
                state: &state,
                status: status,
                count: count,
                startDate: startDate
            )
        )
    }
}

extension PomoTimerFeature {
    
    enum StatusReducers: CaseIterable {
        case liveActivity, status, analyze
        private func myReducer(cancelID: PomoTimerFeature.CancelID) -> TimerStatusProtocol {
            switch self {
            case .liveActivity: LiveActivityReducer(cancelID: cancelID)
            case .status: StatusReducer(cancelID: cancelID)
            case .analyze: AnalyzeReducer(cancelID: cancelID)
            }
        }
        static func makeAllReducers(
            cancelID: PomoTimerFeature.CancelID,
            state: inout PomoTimerFeature.State,
            status:TimerStatus,
            count:Int?,
            startDate:Date?
        ) -> [Effect<PomoTimerFeature.Action>] {
            Self.allCases.map { reducer in
                reducer
                    .myReducer(cancelID: cancelID)
                    .makeReducer(state: &state, status: status, count: count, startDate: startDate)
            }
        }
    }
}
