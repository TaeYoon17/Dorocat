//
//  AppState>LiveActivity.swift
//  Dorocat
//
//  Created by Developer on 4/25/24.
//

import Foundation
import ComposableArchitecture

extension MainFeature.AppStateReducers{
    struct LiveActivityReducer:AppStateReducerProtocol{
        @Dependency(\.pomoLiveActivity) var liveActivity
        func makeReducer(capturedState state: MainFeature.State,
                         prevAppState: DorocatFeature.AppStateType,
                         nextAppState: DorocatFeature.AppStateType) -> Effect<MainFeature.Action> {
            switch nextAppState{
            case .active: return .run{ send in
                switch state.timerProgressEntity.status{
                case .breakTime,.focus: break
                default: await liveActivity.removeActivity()
                }
            }
            case .inActive: return .none
            case .background:
                let totalTime = switch state.timerProgressEntity.status {
                    case .focusSleep: state.timerSettingEntity.timeSeconds
                    case .breakSleep: state.timerSettingEntity.breakTime
                    default: 0
                }
                let lieveActivityType = state.timerProgressEntity.status.convertToTimerActivityType ?? .focusSleep
                switch state.timerProgressEntity.status {
                    case .breakSleep, .focusSleep:
                        return .run { [count = state.timerProgressEntity.count, cat = state.catType] send in
                        await liveActivity.createActivity(
                            type: lieveActivityType,
                            item: state.timerProgressEntity.session,
                            cat: cat,
                            restCount:count,
                            totalCount: totalTime
                        )
                }
                default: return .none
                }
            }
        }
    }
}
