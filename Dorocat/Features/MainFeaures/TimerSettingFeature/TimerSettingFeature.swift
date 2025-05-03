//
//  TimerSettingFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TimerSettingFeature {
    enum SettingType {
        case cycle
        case breakDuration
        // Feature에서 정한 계산 Property
        var range: Range<Int> {
            switch self {
            case .cycle: Range<Int>(2...4)
            case .breakDuration: Range<Int>(1...20)
            }
        }
        
        var title: String {
            switch self {
            case .cycle: "Cycle"
            case .breakDuration: "Break Duration"
            }
        }
    }
    @ObservableState struct State: Equatable {
        var time:String = ""
        var isPomodoroMode: Bool = false
        var cycleTime:Int = 2
        var breakTime:Int = 1
        var timerInfo = TimerSettingEntity()
    }
    
    enum Action:Equatable { // 키패드 접근을 어떻게 할 것인지...
        // View Action...
        case doneTapped
        case setDefaultValues(TimerSettingEntity)
        case setTime(String)
        case setPomodoroMode(Bool)
        case setCycleTime(Int)
        case setBreakTime(Int)
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case cancel
            case setTimerInfo(TimerSettingEntity)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.haptic) var haptic
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .doneTapped:
                let hapticEffect:Effect<Action> = .run { send in
                    await haptic.impact(style: .soft)
                }
                if let time = Int(state.time) {
                    let timerInfo = TimerSettingEntity(
                        timeSeconds: time * 60,
                        cycle: state.cycleTime,
                        breakTime: state.breakTime * 60,
                        isPomoMode: state.isPomodoroMode
                    )
                    return .run { send in
                        await send(.delegate(.setTimerInfo(timerInfo)))
                        await self.dismiss()
                    }
                    .merge(with: hapticEffect)
                } else {
                    return .run { [timerInfo = state.timerInfo] send in
                        await send(.delegate(.setTimerInfo(timerInfo)))
                        await self.dismiss()
                    }
                    .merge(with: hapticEffect)
                }
            case .setTime(let time):
                if time.count > 2 { return .none }
                state.time = time
                return .run { send in
                    await haptic.impact(style: .soft)
                }
            case .setPomodoroMode(let isPomodoro):
                state.isPomodoroMode = isPomodoro
                state.timerInfo.isPomoMode = isPomodoro
                return .run{_ in await haptic.impact(style: .light)}
            case .setCycleTime(let num):
                state.cycleTime = num
                return .none
            case .setBreakTime(let num):
                state.breakTime = num
                return .none
            case .delegate: return .none
            case .setDefaultValues(let info):
                state.timerInfo = info
                state.cycleTime = info.cycle
                state.isPomodoroMode = info.isPomoMode
                state.breakTime = info.breakTime / 60 <= 0 ? 1 : info.breakTime / 60
                state.time = info.timeSeconds / 60 <= 0 ? "" : "\(info.timeSeconds / 60)"
                return .none
            }
        }
    }
}
