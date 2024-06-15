//
//  TimerController>Guide.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature.ControllerReducers{
    struct GuideReducer: TimerControllerProtocol{
        func resetDialogTapped(state: inout TimerFeature.State, type: TimerFeature.ConfirmationDialog) -> Effect<TimerFeature.Action> {
            .none
        }
        
        func sessionTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            .none
        }
        
        @Dependency(\.guideDefaults) var guideDefaults
        func timerFieldTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            if !state.guideInformation.standByGuide{
                state.guideInformation.standByGuide = true
                return .run(operation: {[guides = state.guideInformation] send in
                    await guideDefaults.set(guide: guides)
                })
            }
            return .none
        }
        func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .none
        }
        
        func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .none
        }
        
        func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            if !state.guideInformation.startGuide{
                state.guideInformation.standByGuide = true
                return .run {[guide = state.guideInformation] send in
                    await send(.setGuideState(guide),animation: .easeInOut)
                }
            }
            return .none
        }
        
        func triggerWillTap(state: inout TimerFeature.State,type: TimerFeature.HapticType) -> Effect<TimerFeature.Action>{
            return .none
        }
    }
}
