//
//  TimerController>Notification.swift
//  Dorocat
//
//  Created by Developer on 5/9/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature.ControllerReducers{
    struct NotificationReducer: TimerControllerProtocol{
        func sessionTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            .none
        }
        
        typealias Action = TimerFeature.Action
        @Dependency(\.pomoNotification) var notification
        func timerFieldTapped(state: inout TimerFeature.State) -> ComposableArchitecture.Effect<TimerFeature.Action> {
            .none
        }
        func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .none
        }
        
        func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            .none
        }
        
        func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .standBy:
                return .run { send in
                    if await !notification.isDetermined{
                        _ = try await notification.requestPermission()
                    }
                }
            default: return .none
            }
        }
        func triggerWillTap(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            return .none
        }
    }
}
