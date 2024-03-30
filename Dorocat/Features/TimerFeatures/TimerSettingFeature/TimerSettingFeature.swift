//
//  TimerSettingFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TimerSettingFeature{
    @ObservableState struct State: Equatable{
        var time:String = ""
        var isPomodoroMode: Bool = false
        var cycleTime:Int = 1
        var shortBreak:Int = 1
        var longBreak:Int = 1
        var timerInfo = TimerInformation()
//        init(info:TimerInformation){
//            self.isPomodoroMode = info.isPomoMode
//            self.cycleTime = info.cycle
//            self.shortBreak = info.shortBreak
//            self.longBreak = info.longBreak
//            self.timerInfo = info
//            self.time = "\(info.timeSeconds / 60)"
//        }
    }
    
    enum Action:Equatable{ // 키패드 접근을 어떻게 할 것인지...
        // View Action...
        case doneTapped
        case setDefaultValues(TimerInformation)
        case setTime(String)
        case setPomodoroMode(Bool)
        case setCycleTime(Int)
        case setShortBreak(Int)
        case setLongBreak(Int)
        
        case delegate(Delegate)
        enum Delegate: Equatable{
            case cancel
            case setTimerInfo(TimerInformation)
        }
    }
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .doneTapped:
                return .run {[timerInfo = state.timerInfo] send in
                    await send(.delegate(.setTimerInfo(timerInfo)))
                    await self.dismiss()
                }
            case .setTime(let time):
                state.time = time
                state.timerInfo.timeSeconds = (Int(time) ?? 0)
//                (Int(time) ?? 0) * 60
                return .none
            case .setPomodoroMode(let isPomodoro):
                state.isPomodoroMode = isPomodoro
                state.timerInfo.isPomoMode = isPomodoro
                return .none
            case .setCycleTime(let num):
                state.cycleTime = num
                state.timerInfo.cycle = num
                return .none
            case .setShortBreak(let num):
                state.shortBreak = num
                state.timerInfo.shortBreak = num
                return .none
            case .setLongBreak(let num):
                state.longBreak = num
                state.timerInfo.longBreak = num
                return .none
            case .delegate: return .none
            case .setDefaultValues(let info):
                state.timerInfo = info
                state.cycleTime = info.cycle
                state.isPomodoroMode = info.isPomoMode
                state.longBreak = info.longBreak
                state.shortBreak = info.shortBreak
                state.time = "\(info.timeSeconds)"
//                "\(info.timeSeconds / 60)"
                return .none
            }
        }
    }
}
