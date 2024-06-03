//
//  AppState>LiveActivity.swift
//  Dorocat
//
//  Created by Developer on 4/25/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature.AppStateReducers{
    struct LiveActivityReducer:AppStateReducerProtocol{
        @Dependency(\.pomoLiveActivity) var liveActivity
        func makeReducer(capturedState state: TimerFeature.State,
                         prevAppState: DorocatFeature.AppStateType,
                         nextAppState: DorocatFeature.AppStateType) -> Effect<TimerFeature.Action> {
            switch nextAppState{
            case .active: return .run{ send in
                switch state.timerStatus{
                case .breakTime,.focus: break
                default: await liveActivity.removeActivity()
                }
            }
            case .inActive: return .none
            case .background:
                switch state.timerStatus{
                case .sleep: return .run{[count = state.count,cat = state.catType] send in
                    let lieveActivityType = state.timerStatus.convertToTimerActivityType
                    await liveActivity.updateActivity(type: lieveActivityType  ?? .focusSleep,
                                                      item: state.selectedSession, cat: cat,restCount: count)
                    }
                default: return .none
                }
            }
        }
    }
}
