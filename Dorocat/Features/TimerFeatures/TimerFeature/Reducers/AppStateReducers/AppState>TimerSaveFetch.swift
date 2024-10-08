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
        @Dependency(\.timer.background) var timerBackground
        @Dependency(\.pomoDefaults) var pomoDefaults
        @Dependency(\.analyzeAPIClients) var analyzeAPI
        func makeReducer(capturedState state: TimerFeature.State, prevAppState: DorocatFeature.AppStateType, nextAppState: DorocatFeature.AppStateType) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            print("-- App State ","prev: ",prevAppState,"next: ",nextAppState)
            switch nextAppState {
            case .active:
                switch prevAppState {
                case .inActive:
                    return .run { send in
                        await send(.diskInfoToMemory)
                    }
                default:
                    return .run { send in
                        await timerBackground.set(date: Date())
                    }
                }
            case .inActive:
                switch prevAppState{
                case .background: return .none
                case .active:
                    let prevStatus = state.timerStatus
                    let timerStatus = TimerFeatureStatus.getSleep(prevStatus) ?? prevStatus
                    let values = PomoValues(catType: state.catType,
                                            status: prevStatus,
                                            information: state.timerInformation,
                                            cycle: state.cycle,
                                            count: state.count,
                                            sessionItem: state.selectedSession,
                                            startDate: state.startDate)
                    return .run { send in
                        await timerBackground.set(date: Date())
                        await timerBackground.set(timerStatus: timerStatus)
                        await send(.setStatus(timerStatus))
                        await pomoDefaults.setAll(values)
                    }
                case .inActive: return .none
                }
            case .background: return .none
            }
        }
    }
}

