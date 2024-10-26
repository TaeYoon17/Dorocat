//
//  AppState>Notification.swift
//  Dorocat
//
//  Created by Developer on 4/25/24.
//

import ComposableArchitecture

extension MainFeature.AppStateReducers{
    struct NotificationReducer:AppStateReducerProtocol{
        @Dependency(\.pomoNotification) var notification
        func makeReducer(capturedState state: MainFeature.State, prevAppState: DorocatFeature.AppStateType, nextAppState: DorocatFeature.AppStateType) -> Effect<MainFeature.Action> {
            switch nextAppState {
            case .active:
                    return .run{ _ in try await removeAllNotifications() }
            case .inActive: return .none
            case .background:
                let prevStatus = state.timerProgressEntity.status
                let values = PomoValues(catType: state.catType,
                                        status: prevStatus,
                                        information: state.timerSettingEntity,
                                        cycle: state.timerProgressEntity.cycle,
                                        count: state.timerProgressEntity.count,
                                        startDate: state.timerProgressEntity.startDate)
                return .run{ send in
                    try await self.setNotification(send: send, status: prevStatus, value: values)
                }
            }
        }
    }
}

extension MainFeature.AppStateReducers.NotificationReducer{
    fileprivate func removeAllNotifications()async throws{
        try await notification.removeAllNotifications()
    }
    fileprivate func setNotification(send:Send<MainFeature.Action>,status: TimerStatus,value:PomoValues) async throws {
        switch status{
        case .breakStandBy,.focusStandBy,.completed,.standBy,.pause: break
        case .breakTime,.sleep(.breakSleep):
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
        case .focus,.sleep(.focusSleep):
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
