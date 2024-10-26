//
//  TimerController>Guide.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture



extension MainFeature.ControllerReducers{
    struct GuideReducer: TimerControllerProtocol{
        typealias MainConfrimationDialog = MainFeature.ConfirmationDialog
        
        @Dependency(\.guideDefaults) var guideDefaults
        func timerFieldTapped(state: inout MainState) -> MainEffect {
            if !state.guideInformation.standByGuide{
                state.guideInformation.standByGuide = true
                return .run(operation: {[guides = state.guideInformation] send in
                    await guideDefaults.set(guide: guides)
                })
            }
            return .none
        }
        
        func resetDialogTapped(state: inout MainState, type: MainConfrimationDialog) -> MainEffect { .none }
        func sessionTapped(state: inout MainState) -> MainEffect { .none }
        func catTapped(state: inout MainState) -> MainEffect { .none }
        func resetTapped(state: inout MainState) -> MainEffect { .none }
        
        func triggerTapped(state: inout MainState) -> MainEffect {
            if !state.guideInformation.startGuide{
                state.guideInformation.standByGuide = true
                return .run {[guide = state.guideInformation] send in
                    await send(.setGuideState(guide),animation: .easeInOut)
                }
            }
            return .none
        }
        
        func triggerWillTap(state: inout MainState,type: MainFeature.HapticType) -> MainEffect{ .none
        }
    }
}
