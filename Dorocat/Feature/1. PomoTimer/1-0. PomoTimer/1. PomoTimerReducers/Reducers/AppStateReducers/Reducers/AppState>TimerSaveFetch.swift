//
//  AppState>Timer.swift
//  Dorocat
//
//  Created by Developer on 4/25/24.
//

import Foundation
import ComposableArchitecture

extension PomoTimerFeature.AppStateReducers{
    struct TimerReducer: AppStateReducerProtocol{
        @Dependency(\.timer.background) var timerBackground
//        @Dependency(\.pomoDefaults) var pomoDefaults
        @Dependency(\.doroStateDefaults) var doroStateDefaults
        @Dependency(\.analyzeAPIClients) var analyzeAPI
        func makeReducer(capturedState state: PomoTimerFeature.State, prevAppState: DorocatFeature.AppStateType, nextAppState: DorocatFeature.AppStateType) -> ComposableArchitecture.Effect<PomoTimerFeature.Action> {
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
                    let entity = DoroStateEntity(catType: state.catType,
                                                 isProMode: state.isProUser,
                                                 progressEntity: state.timerProgressEntity, settingEntity: state.timerSettingEntity)
                    return .run { send in
                        await timerBackground.set(date: Date())
                        await timerBackground.set(timerStatus: timerStatus)
                        await send(.setStatus(timerStatus))
                        await doroStateDefaults.setDoroStateEntity(entity)
                    }
                case .inActive: return .none
                }
            case .background: return .none
            }
        }
    }
}

