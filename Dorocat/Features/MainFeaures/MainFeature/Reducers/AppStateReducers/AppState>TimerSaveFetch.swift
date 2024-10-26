//
//  AppState>Timer.swift
//  Dorocat
//
//  Created by Developer on 4/25/24.
//

import Foundation
import ComposableArchitecture

extension MainFeature.AppStateReducers{
    struct TimerReducer: AppStateReducerProtocol{
        @Dependency(\.timer.background) var timerBackground
        @Dependency(\.pomoDefaults) var pomoDefaults
        @Dependency(\.analyzeAPIClients) var analyzeAPI
        func makeReducer(capturedState state: MainFeature.State, prevAppState: DorocatFeature.AppStateType, nextAppState: DorocatFeature.AppStateType) -> ComposableArchitecture.Effect<MainFeature.Action> {
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
                    let prevStatus = state.timerProgressEntity.status
                    let timerStatus = TimerStatus.getSleep(prevStatus) ?? prevStatus
                    let values = PomoValues(catType: state.catType,
                                            status: prevStatus,
                                            information: state.timerSettingEntity,
                                            cycle: state.timerProgressEntity.cycle,
                                            count: state.timerProgressEntity.count,
                                            sessionItem: state.timerProgressEntity.session,
                                            startDate: state.timerProgressEntity.startDate)
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

