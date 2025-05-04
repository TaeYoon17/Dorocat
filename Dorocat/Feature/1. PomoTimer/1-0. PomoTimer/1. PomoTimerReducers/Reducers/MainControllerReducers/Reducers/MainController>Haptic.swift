//
//  TimerController>Haptic.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
extension PomoTimerFeature.Controller{
    struct HapticReducer: MainControllerProtocol{
        @Dependency(\.haptic) var haptic
        
        func resetDialogTapped(state: inout PomoTimerFeature.State,
                               type: PomoTimerFeature.ConfirmationDialog) -> Effect<PomoTimerFeature.Action> {
            return .run { send in
                await haptic.impact(style: .soft)
            }
        }
        func sessionTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {
            .run { send in
                await haptic.impact(style: .soft)
            }
        }
        func timerFieldTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {
            if !state.guideInformation.onBoardingFinished{
                return .run { send in await haptic.impact(style: .soft) }
            }
            switch state.timerProgressEntity.status{
            case .standBy: return .run { send in
                await haptic.impact(style: .soft)
            }
            default: return .none
            }
        }
        
        func catTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {
            return .run { send in
                await haptic.impact(style: .rigid,intensity: 0.7)
            }
        }
        
        func resetTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {
            return .run { send in
                await haptic.impact(style: .soft)
            }
        }
        
        func triggerTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {
            let hapticEffect: Effect<PomoTimerFeature.Action> = .run { send in
                await haptic.impact(style: .light)
            }
            return hapticEffect
        }
        
        func triggerWillTap(state: inout PomoTimerFeature.State,type: PomoTimerFeature.HapticType) -> ComposableArchitecture.Effect<PomoTimerFeature.Action> {
            switch type{
            case .heavy: return .run { send in
                await haptic.impact(style: .heavy)
            }
            case .soft: return .run { send in
                await haptic.impact(style: .soft)
            }
            }
        }
    }
}
