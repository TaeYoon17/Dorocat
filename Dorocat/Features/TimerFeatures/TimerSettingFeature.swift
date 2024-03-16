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
    }
    
    enum Action:Equatable{ // 키패드 접근을 어떻게 할 것인지...
        case cancelTapped
        case doneTapped
        case setTime(String)
        case setPomodoroMode(Bool)
        case delegate(Delegate)
        enum Delegate: Equatable{
            case cancel
            case triggerTimer(Int)
        }
    }
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .cancelTapped:
                print("cancelTapped!!")
                return .run { _ in
                    await self.dismiss()
                }
            case .doneTapped:
                return .run {[strTime = state.time] send in
                    await send(.delegate(.triggerTimer(Int(strTime)!)))
                    await self.dismiss()
                }
            case .setTime(let time):
                state.time = time
                return .none
            case .delegate: return .none
            case .setPomodoroMode(let isPomodoro):
                state.isPomodoroMode = isPomodoro
                return .none
            }
        }
    }
}
