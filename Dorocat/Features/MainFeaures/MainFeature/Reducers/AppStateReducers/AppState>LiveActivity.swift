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
                switch state.timerProgressEntity.status{
                case .sleep(let sleepType): return .run{[count = state.timerProgressEntity.count, cat = state.catType] send in
                    let lieveActivityType: TimerActivityType = state.timerProgressEntity.status.convertToTimerActivityType ?? .focusSleep
                    let totalTime:Int = switch sleepType {
                        case .focusSleep: state.timerSettingEntity.timeSeconds
                        case .breakSleep: state.timerSettingEntity.breakTime
                    }
                    await liveActivity.createActivity(type: lieveActivityType ,item: state.timerProgressEntity.session,
                                                      cat: cat ,restCount:count,totalCount: totalTime)
                    }
                    
                default: return .none
                }
            }
        }
    }
}
