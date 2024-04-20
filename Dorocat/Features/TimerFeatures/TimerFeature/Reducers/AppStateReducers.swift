//
//  AppStateReducers.swift
//  Dorocat
//
//  Created by Developer on 4/9/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature{
    func appStateRedecuer(_ state: inout TimerFeature.State,appState: DorocatFeature.AppStateType)-> Effect<Action>{
        let prevState = state.appState
        state.appState = appState
        switch appState{
        case .active:// background 시간 없애주기...
            return .run { send in
                try await removeAllNotifications()
                await timeBackground.set(date: nil)
            }
        case .inActive:
            switch prevState{
            case .background: return diskTimerInfoToMemory
            default: return .none
                /// 앞으로 background로 이동할 상태
                /// 현재 진행상황 저장 - background로 이동시 무조건 타이머 상태는 pause가 되도록 설정한다.
                /*
                let prevStatus = state.timerStatus // 이전에 갖고 있던 상태를 그대로 저장
                let pauseStatus = TimerFeatureStatus.getPause(state.timerStatus) ?? state.timerStatus
                // 이전에 갖고 있던 상태에서 Pause로 이동한 상태를 저장
                let values = PomoValues(status: pauseStatus, information: state.timerInformation, cycle: state.cycle, count: state.count,startDate: state.startDate)
                return .run { send in
                    try await self.setNotification(send: send, status: prevStatus, value: values)
                    await timeBackground.set(date: Date())
                    await timeBackground.set(timerStatus: prevStatus)
                    await send(.setStatus(pauseStatus))
                    await pomoDefaults.setAll(values)
                }
                 */
            }
        case .background: return .none
            let prevStatus = state.timerStatus // 이전에 갖고 있던 상태를 그대로 저장
            let pauseStatus = TimerFeatureStatus.getPause(state.timerStatus) ?? state.timerStatus
            // 이전에 갖고 있던 상태에서 Pause로 이동한 상태를 저장
            let values = PomoValues(status: pauseStatus, information: state.timerInformation, cycle: state.cycle, count: state.count,startDate: state.startDate)
            return .run { send in
                try await self.setNotification(send: send, status: prevStatus, value: values)
                await timeBackground.set(date: Date())
                await timeBackground.set(timerStatus: prevStatus)
                await send(.setStatus(pauseStatus))
                await pomoDefaults.setAll(values)
            }
        }
    }
    
}

extension TimerFeature{
    /// 앱을 시작할 때, inActive로 돌아올 때, 디스크에 저장되어 남았던 데이터를 가져옴
    var diskTimerInfoToMemory:Effect<TimerFeature.Action>{
        .run { send in
            // Realm 객체 생성
            try await analyzeAPI.initAction()
            await awakeTimer(send)
        }
    }
}
//MARK: -- 노티피케이션 관련
extension TimerFeature{
    fileprivate func removeAllNotifications()async throws{
        try await notification.removeAllNotifications()
    }
    fileprivate func setNotification(send:Send<TimerFeature.Action>,status: TimerFeatureStatus,value:PomoValues) async throws {
        print("setNotification called")
        switch status{
        case .breakStandBy,.completed,.standBy,.pause: break
        case .breakTime:
            guard let information = value.information else {fatalError("정보가 없음!!")}
            try await notification.sendNotification(message: .breakTimeToFocus(focusTime: information.timeSeconds),
                                                    restSeconds: value.count)
            let restCycle = information.cycle - value.cycle
            let sessionSeconds = value.count + information.timeSeconds
            if restCycle == 1{
                try await notification.sendNotification(message: .complete, restSeconds: sessionSeconds)
            }else{
                try await notification.sendNotification(message: .sessionComplete(breakTime: information.breakTime),
                                                        restSeconds: sessionSeconds)
            }
        case .focus:
            guard let information = value.information else {fatalError("정보가 없음!!")}
            if information.isPomoMode{
                try? await notification.sendNotification(message: .complete, restSeconds: value.count)
            }else{
                let restCycle = information.cycle - value.cycle
                if restCycle == 1{
                    try await notification.sendNotification(message: .complete, restSeconds: value.count)
                }else{
                    try await notification.sendNotification(message: .sessionComplete(breakTime: information.breakTime), restSeconds: value.count)
                }
            }
        }
    }
}
