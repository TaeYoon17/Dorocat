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
            let values: DoroStateEntity = DoroStateEntity(catType: state.catType,
                                                          isProMode: state.isProUser,
                                                          progressEntity: state.timerProgressEntity,
                                                          settingEntity: state.timerSettingEntity)
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
    fileprivate func setNotification(send:Send<MainFeature.Action>,
                                     status: TimerStatus,
                                     value:DoroStateEntity
    ) async throws {
        let settingEntity = value.settingEntity
        let progressEntity = value.progressEntity
        let restCycle = settingEntity.cycle - progressEntity.cycle
        switch status{
        case .breakTime,.breakSleep:
            try await notification.sendNotification(message:
                    .breakTimeToFocus(focusMinutes: settingEntity.timeSeconds / 60),
                                                    restSeconds: progressEntity.count)
            let sessionSeconds = progressEntity.count + settingEntity.timeSeconds
            if restCycle == 1{
                try await notification.sendNotification(message: .complete,
                                                        restSeconds: sessionSeconds)
            }else{
                try await notification.sendNotification(message:
                        .sessionComplete(breakMinutes: settingEntity.breakTime / 60),
                                                        restSeconds: sessionSeconds)
            }
        case .focus,.focusSleep:
            if settingEntity.isPomoMode && restCycle != 1 {
                    try await notification.sendNotification(message:
                            .sessionComplete(breakMinutes: settingEntity.breakTime / 60),
                                                            restSeconds: progressEntity.count)
            } else {
                try? await notification.sendNotification(message: .complete,
                                                         restSeconds: progressEntity.count)
            }
        case .breakStandBy,.focusStandBy,.completed,.standBy,.pause: break
        }
    }
}
