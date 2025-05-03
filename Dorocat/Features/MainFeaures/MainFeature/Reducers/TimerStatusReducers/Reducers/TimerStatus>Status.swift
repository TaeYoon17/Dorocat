//
//  TimerStatus>Status.swift
//  Dorocat
//
//  Created by Developer on 5/8/24.
//

import Foundation
import ComposableArchitecture

extension MainFeature.StatusReducers{
    struct StatusReducer: TimerStatusProtocol{
        
        @Dependency(\.haptic) var haptic
        @Dependency(\.doroStateDefaults) var doroStateDefaults
        var cancelID: MainFeature.CancelID
        func setStandBy(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> {
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            state.timerProgressEntity.cycle = 0
            state.timerProgressEntity.count = state.timerSettingEntity.timeSeconds
            return .cancel(id: cancelID)
        }
        
        func setFocus(state: inout MainFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<MainFeature.Action> {
            if let startDate{ state.timerProgressEntity.startDate = startDate }
            let count = count ?? state.timerSettingEntity.timeSeconds
            state.timerProgressEntity.count = count
            // Focus에서 나오는 Set Sleep을 감춘다.
            var guides = state.guideInformation
            guides.startGuide = true
            return .concatenate(.cancel(id: cancelID),
                                .run(priority: .high)  { send in
                                    await send(.setTimerRunning(count))
                                },.run(operation: {[guides] send in
                                    try await Task.sleep(for: .seconds(2))
                                    await send(.setGuideState(guides))
                                }).animation(.easeInOut))
        }
        
        func setPause(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> {
            return .cancel(id: cancelID)
        }
        
        func setSleep(state: inout MainFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<MainFeature.Action> {
            if let count { fatalError("여기에 존재하면 안된다!!")}
            print("Sleep 모드로 타이머 전환")
            return .cancel(id: cancelID)
        }
        func setBreakTime(state: inout MainFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<MainFeature.Action> {
            if let startDate{state.timerProgressEntity.startDate = startDate}
            let count = count ?? state.timerSettingEntity.breakTime
            state.timerProgressEntity.count = count
            return .concatenate(.cancel(id: cancelID),.run(priority: .high) { send in
                await send(.setTimerRunning(count))
            })
        }
        func setBreakStandBy(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> {
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            state.timerProgressEntity.count = state.timerSettingEntity.breakTime
            return .concatenate(.cancel(id: cancelID))
        }
        func setFocusStandBy(state: inout MainFeature.State, count: Int?, startDate: Date?) -> Effect<MainFeature.Action> {
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            state.timerProgressEntity.count = state.timerSettingEntity.timeSeconds
            return .concatenate(.cancel(id: cancelID))
        }
        
        func setCompleted(state: inout MainFeature.State, count: Int?, startDate: Date?) -> ComposableArchitecture.Effect<MainFeature.Action> {
            if count != nil{ fatalError("여기에 존재하면 안된다!!")}
            return .concatenate(.cancel(id: cancelID),.run(operation: {[appstate = state.appState] send in
                switch appstate{
                case .active:
                    await haptic.notification(type: .success)
                default: break
                }
            }))
        }
    }
}
