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
    func setTimerStatus(
        state:inout MainFeature.State,
        status:TimerStatus,
        count:Int? = nil,
        startDate:Date? = nil
    ) -> Effect<MainFeature.Action> {
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

extension MainFeature {
    
    enum StatusReducers: CaseIterable {
        case liveActivity, status, analyze
        private func myReducer(cancelID: MainFeature.CancelID) -> TimerStatusProtocol {
            switch self {
            case .liveActivity: LiveActivityReducer(cancelID: cancelID)
            case .status: StatusReducer(cancelID: cancelID)
            case .analyze: AnalyzeReducer(cancelID: cancelID)
            }
        }
        static func makeAllReducers(
            cancelID: MainFeature.CancelID,
            state: inout MainFeature.State,
            status:TimerStatus,
            count:Int?,
            startDate:Date?
        ) -> [Effect<MainFeature.Action>] {
            Self.allCases.map { reducer in
                reducer
                    .myReducer(cancelID: cancelID)
                    .makeReducer(state: &state, status: status, count: count, startDate: startDate)
            }
        }
    }
}
