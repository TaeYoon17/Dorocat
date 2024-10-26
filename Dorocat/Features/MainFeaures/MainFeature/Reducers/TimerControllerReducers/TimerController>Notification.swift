//
//  TimerController>Notification.swift
//  Dorocat
//
//  Created by Developer on 5/9/24.
//

import Foundation
import ComposableArchitecture

extension MainFeature.ControllerReducers{
    struct NotificationReducer: TimerControllerProtocol{
        func resetDialogTapped(state: inout MainFeature.State, type: MainFeature.ConfirmationDialog) -> Effect<MainFeature.Action> {
            .none
        }
        
        func sessionTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
            .none
        }
        
        typealias Action = MainFeature.Action
        @Dependency(\.pomoNotification) var notification
        func timerFieldTapped(state: inout MainFeature.State) -> ComposableArchitecture.Effect<MainFeature.Action> {
            .none
        }
        func catTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
            return .none
        }
        
        func resetTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
            .none
        }
        
        func triggerTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action> {
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
        func triggerWillTap(state: inout MainFeature.State,type: MainFeature.HapticType) -> Effect<MainFeature.Action>{
            return .none
        }
    }
}
