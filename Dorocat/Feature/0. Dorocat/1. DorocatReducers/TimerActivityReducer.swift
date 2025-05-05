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
        @Dependency(\.cat) var cat
        @Dependency(\.timer) var timer
        return .run { send in
            guard let prevDate = await timerBackground.date else {
                print("이게 문제")
                return
            }
            if Date().isOverTwoDays(prevDate: prevDate){
                return
            }
            let difference = Int(Date().timeIntervalSince(prevDate))
            let pomoDefaultsValue:DoroStateEntity = await doroStateDefaults.getDoroStateEntity()
            
            let sessionItem = pomoDefaultsValue.progressEntity.session
            let restTime = pomoDefaultsValue.progressEntity.count
            
            let timerTotalTime = pomoDefaultsValue.settingEntity.timeSeconds ?? 0
            
            let differenceTime = restTime - difference
            if next == .pause && differenceTime <= 0 {
                ActivityIntentManager.setTimerActivityType(prev)
                return
            }
            await timerBackground.set(date: Date())
            
            switch next{
            case .breakSleep: break
            case .focusSleep:
                var doroStateEntity = await doroStateDefaults.getDoroStateEntity()
                doroStateEntity.progressEntity.status = .focus
                await timer.setTimerProgressEntity(doroStateEntity.progressEntity)
                await timerBackground.set(timerStatus: .focusSleep)
                await liveActivity.updateActivity(
                    type:.focusSleep,
                    item:doroStateEntity.progressEntity.session,
                    cat: await cat.selectedCat,
                    restCount: restTime
                )
                try? await setFocusSleepNotification(entity: doroStateEntity)
            case .pause:
                var doroStateEntity = await doroStateDefaults.getDoroStateEntity()
                let differenceTime = doroStateEntity.progressEntity.count - difference
                if differenceTime <= 0{
                    ActivityIntentManager.setTimerActivityType(prev)
                    return
                }else{
                    doroStateEntity.progressEntity.count = differenceTime
                    doroStateEntity.progressEntity.status = .pause
                    await liveActivity.updateActivity(
                        type: .pause,
                        item: sessionItem,
                        cat: await cat.selectedCat,
                        restCount: differenceTime
                    )
                    await doroStateDefaults.setDoroStateEntity(doroStateEntity)
                    try await notification.removeAllNotifications()
                }
            case .standBy:
                var doroStateEntity = await doroStateDefaults.getDoroStateEntity()
                let differenceTime = doroStateEntity.progressEntity.count - difference
                guard differenceTime > 0 else { return } // 0보다 작으면 이미
                doroStateEntity.progressEntity.count = timerTotalTime
                doroStateEntity.progressEntity.status = .standBy
                await liveActivity.updateActivity(
                    type: .standBy,
                    item: sessionItem,
                    cat: await cat.selectedCat,
                    restCount: 0
                )
                await doroStateDefaults.setDoroStateEntity(doroStateEntity)
            }
        }
    }
    
    private func setFocusSleepNotification(entity: DoroStateEntity) async throws{
        if entity.settingEntity.isPomoMode{
            let restCycle = entity.settingEntity.cycle - entity.progressEntity.cycle
            if restCycle == 1{
                try await notification.sendNotification(message: .complete, restSeconds: entity.progressEntity.count)
            }else{
                try await notification.sendNotification(message: .sessionComplete(breakMinutes: entity.settingEntity.breakTime / 60), restSeconds: entity.progressEntity.count)
            }
        }else{
            try? await notification.sendNotification(message: .complete, restSeconds: entity.progressEntity.count)
        }
    }
}
