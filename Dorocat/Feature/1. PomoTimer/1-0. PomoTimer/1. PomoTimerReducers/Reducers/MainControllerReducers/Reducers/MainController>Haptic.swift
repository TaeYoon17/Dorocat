//
//  TimerController>Haptic.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
extension MainFeature.Controller{
    struct HapticReducer: MainControllerProtocol{
        @Dependency(\.haptic) var haptic
        
        func resetDialogTapped(state: inout MainFeature.State,
                               type: MainFeature.ConfirmationDialog) -> Effect<MainFeature.Action> {
            return .run { send in
                await haptic.impact(style: .soft)
            }
        }
        func sessionTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
            .run { send in
                await haptic.impact(style: .soft)
            }
        }
        func timerFieldTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
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
        
        func catTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
            return .run { send in
                await haptic.impact(style: .rigid,intensity: 0.7)
            }
        }
        
        func resetTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
            return .run { send in
                await haptic.impact(style: .soft)
            }
        }
        
        func triggerTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
            let hapticEffect: Effect<MainFeature.Action> = .run { send in
                await haptic.impact(style: .light)
            }
            return hapticEffect
        }
        
        func triggerWillTap(state: inout MainFeature.State,type: MainFeature.HapticType) -> ComposableArchitecture.Effect<MainFeature.Action> {
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
