//
//  TimerController>Notification.swift
//  Dorocat
//
//  Created by Developer on 5/9/24.
//

import Foundation
import ComposableArchitecture

extension PomoTimerFeature.Controller{
    struct NotificationReducer: MainControllerProtocol{
        func resetDialogTapped(state: inout PomoTimerFeature.State,
                               type: PomoTimerFeature.ConfirmationDialog) -> Effect<PomoTimerFeature.Action> {
            .none
        }
        
        func sessionTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {
            .none
        }
        
        typealias Action = PomoTimerFeature.Action
        @Dependency(\.pomoNotification) var notification
        func timerFieldTapped(state: inout PomoTimerFeature.State) -> ComposableArchitecture.Effect<PomoTimerFeature.Action> {
            .none
        }
        func catTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> { .none }
        
        func resetTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {.none }
        
        func triggerTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action> {
            switch state.timerProgressEntity.status {
            case .standBy:
                return .run { send in
                    if await !notification.isDetermined{
                        _ = try await notification.requestPermission()
                    }
                }
            default: return .none
            }
        }
        func triggerWillTap(state: inout PomoTimerFeature.State,type: PomoTimerFeature.HapticType) -> Effect<PomoTimerFeature.Action>{
            return .none
        }
    }
}
