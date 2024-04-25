//
//  AppState>Timer.swift
//  Dorocat
//
//  Created by Developer on 4/25/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature.AppStateReducers{
    struct TimerReducer: AppStateReducerProtocol{
        @Dependency(\.timeBackground) var timerBackground
        @Dependency(\.pomoDefaults) var pomoDefaults
        @Dependency(\.analyzeAPIClients) var analyzeAPI
        func makeReducer(capturedState state: TimerFeature.State, prevAppState: DorocatFeature.AppStateType, nextAppState: DorocatFeature.AppStateType) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            switch nextAppState {
            case .active:
                return .run { send in
                    await timerBackground.set(date: Date())
                }
            case .inActive:
                switch prevAppState{
                case .background: return .run { send in
                    await send(.diskInfoToMemory)
                }
                default: return .none
                }
            case .background:
                // 이전에 갖고 있던 상태에서 Pause로 이동한 상태를 저장
                let prevStatus = state.timerStatus
                let timerStatus = TimerFeatureStatus.getSleep(prevStatus) ?? prevStatus
                let values = PomoValues(status: prevStatus, information: state.timerInformation, cycle: state.cycle, count: state.count,startDate: state.startDate)
                return .run { send in
                    await timerBackground.set(date: Date())
                    await timerBackground.set(timerStatus: timerStatus)
                    await send(.setStatus(timerStatus))
                    await pomoDefaults.setAll(values)
                }
            }
        }
    }
}

