//
//  AppState>Notification.swift
//  Dorocat
//
//  Created by Developer on 4/25/24.
//

import ComposableArchitecture

extension TimerFeature.AppStateReducers{
    struct NotificationReducer:AppStateReducerProtocol{
        @Dependency(\.pomoNotification) var notification
        func makeReducer(capturedState state: TimerFeature.State, prevAppState: DorocatFeature.AppStateType, nextAppState: DorocatFeature.AppStateType) -> Effect<TimerFeature.Action> {
            switch nextAppState {
            case .inActive: return .none
            case .active:
                    return .run{ send in
                        try await removeAllNotifications()
                    }
            case .background:
                    let prevStatus = state.timerStatus
                    let values = PomoValues(status: prevStatus, information: state.timerInformation, cycle: state.cycle, count: state.count,startDate: state.startDate)
                    return .run{ send in
                        try await self.setNotification(send: send, status: prevStatus, value: values)
                    }
            }
        }
    }
}

extension TimerFeature.AppStateReducers.NotificationReducer{
    fileprivate func removeAllNotifications()async throws{
        try await notification.removeAllNotifications()
    }
    fileprivate func setNotification(send:Send<TimerFeature.Action>,status: TimerFeatureStatus,value:PomoValues) async throws {
        print("setNotification called")
        switch status{
        case .breakStandBy,.completed,.standBy,.pause,.sleep: break
        case .breakTime:
            guard let information = value.information else {fatalError("정보가 없음!!")}
            try await notification.sendNotification(message: .breakTimeToFocus(focusMinutes: information.timeSeconds / 60),
                                                    restSeconds: value.count)
            let restCycle = information.cycle - value.cycle
            let sessionSeconds = value.count + information.timeSeconds
            if restCycle == 1{
                try await notification.sendNotification(message: .complete, restSeconds: sessionSeconds)
            }else{
                try await notification.sendNotification(message: .sessionComplete(breakMinutes: information.breakTime / 60),
                                                        restSeconds: sessionSeconds)
            }
        case .focus:
            guard let information = value.information else {fatalError("정보가 없음!!")}
            if information.isPomoMode{
                let restCycle = information.cycle - value.cycle
                if restCycle == 1{
                    try await notification.sendNotification(message: .complete, restSeconds: value.count)
                }else{
                    try await notification.sendNotification(message: .sessionComplete(breakMinutes: information.breakTime / 60), restSeconds: value.count)
                }
            }else{
                try? await notification.sendNotification(message: .complete, restSeconds: value.count)
            }
        }
    }
}
