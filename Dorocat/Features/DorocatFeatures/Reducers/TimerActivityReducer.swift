//
//  TimerActivityReducer.swift
//  Dorocat
//
//  Created by Developer on 5/18/24.
//

import Foundation
import ComposableArchitecture
/// 사용 Dependency
/// 1. timeBackground
/// 2. pomoDefaults
/// 3. notification
/// 4. liveActivity
extension DorocatFeature{
    func timerActivityReducer(state: inout State,prev:TimerActivityType,next:TimerActivityType) -> Effect<Action>{
        liveActivityReducer(state: &state, prev: prev, next: next)
    }
}
fileprivate extension DorocatFeature{
    func liveActivityReducer(state: inout State,prev:TimerActivityType,next:TimerActivityType)->Effect<Action>{
        return .run { send in
            guard let prevDate = await timerBackground.date else {
                print("이게 문제")
                return
            }
            if Date().isOverTwoDays(prevDate: prevDate){
                return
            }
            await timerBackground.set(date: Date())
            let difference = Int(Date().timeIntervalSince(prevDate))
            let pomoDefaultsValue:PomoValues = await pomoDefaults.getAll()
            let sessionItem = pomoDefaultsValue.sessionItem
            let restTime = pomoDefaultsValue.count
            let timerTotalTime = pomoDefaultsValue.information?.timeSeconds ?? 0
            print("바뀐 세션 아이템 \(sessionItem)")
            switch next{
            case .breakSleep: break
            case .focusSleep:
                await pomoDefaults.setStatus(.focus)
                await timerBackground.set(timerStatus: .sleep(.focusSleep))
                await liveActivity.updateActivity(type:.focusSleep,item:pomoDefaultsValue.sessionItem, cat: pomoDefaultsValue.catType,restCount: restTime)
                try? await setFocusSleepNotification(pomoDefaultValue: pomoDefaultsValue)
            case .pause:
                var differenceTime = await pomoDefaults.getAll().count - difference - 1
                differenceTime = max(0, differenceTime)
                await pomoDefaults.setCount(differenceTime)
                await pomoDefaults.setStatus(.pause)
                await liveActivity.updateActivity(type: .pause,item: sessionItem, cat: pomoDefaultsValue.catType, restCount: differenceTime)
                try await notification.removeAllNotifications()
            case .standBy:
                let differenceTime = await pomoDefaults.getAll().count - difference
                guard differenceTime > 0 else { return } // 0보다 작으면 이미
                await pomoDefaults.setCount(timerTotalTime)
                await pomoDefaults.setStatus(.standBy)
                await liveActivity.updateActivity(type: .standBy,
                                                  item: sessionItem,
                                                  cat: pomoDefaultsValue.catType,
                                                  restCount: 0)
            }
        }
    }
    private func setFocusSleepNotification(pomoDefaultValue value: PomoValues) async throws{
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
