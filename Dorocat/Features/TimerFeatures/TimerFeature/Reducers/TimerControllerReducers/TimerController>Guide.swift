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
        func catTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            return .none
        }
        
        func resetTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            return .none
        }
        
        func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            if !state.guideInformation.onBoarding{
                state.guideInformation.onBoarding = true
                var guide = state.guideInformation
                guide.startGuide = true
                return .run {[guide] send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.setGuideState(guide),animation: .easeInOut)
                }
            }
            return .none
        }
        
        func triggerWillTap(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .none
        }
    }
}
