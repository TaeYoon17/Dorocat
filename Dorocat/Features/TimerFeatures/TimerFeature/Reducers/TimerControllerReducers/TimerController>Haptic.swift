//
//  TimerController>Haptic.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature.ControllerReducers{
    struct HapticReducer: TimerControllerProtocol{
        @Dependency(\.haptic) var haptic
        
        func sessionTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            .run { send in
                await haptic.impact(style: .soft)
            }
        }
        func timerFieldTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            if !state.guideInformation.onBoarding{
                return .run { send in await haptic.impact(style: .soft) }
            }
            switch state.timerStatus{
            case .standBy: return .run { send in
                await haptic.impact(style: .soft)
                }
            default: return .none
            }
        }
        
        func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .run { send in
                await haptic.impact(style: .rigid,intensity: 0.7)
            }
        }
        
        func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .run { send in
                await haptic.notification(type: .warning)
            }
        }
        
        func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            let hapticEffect: Effect<TimerFeature.Action> = .run { send in
                await haptic.impact(style: .light)
            }
            return hapticEffect
        }
        
        func triggerWillTap(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .completed,.breakStandBy,.breakTime,.standBy,.focus,.pause:
                return .run { send in
                    await haptic.impact(style: .heavy)
                }
            default: return .none
            }
        }
    }
}
