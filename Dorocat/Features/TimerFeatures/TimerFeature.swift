//
//  TimerFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture
// MARK: -- Dorocat Tab과 Feature를 완전히 분리해서 구현해보기
@Reducer struct TimerFeature{
    @ObservableState struct State: Equatable{
        var timer = "00 : 00"
        var count = 0
        var isTimerRunning = false
        @Presents var timerSetting: TimerSettingFeature.State?
    }
    
    enum Action:Equatable{
        case stopTapped
        case timerTick
        case setTimer(Int)
        case goTimerSetting
        case timerSetting(PresentationAction<TimerSettingFeature.Action>)
    }
    enum CancelID { case timer }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .stopTapped:
                state.isTimerRunning = false
                return .cancel(id: CancelID.timer)
            case .timerTick:
                state.count -= 1
                print("Next Timer tick \(state.count)")
                if state.count > 0{
                    return .run {[intTimer = state.count] send in
                        await send(.setTimer(intTimer))
                    }
                }else{
                    state.isTimerRunning = false
                    return .concatenate(.cancel(id: CancelID.timer),
                                        .run(operation: { send in
                        await send(.setTimer(0))
                    }))
                }
            case .goTimerSetting:
                state.timerSetting = TimerSettingFeature.State()
                state.isTimerRunning = false
                return .none
            case .setTimer(let intTime):
                state.timer =  "\(intTime / 60) : \(intTime % 60)"
                return .none
            case .timerSetting(.presented(.delegate(.cancel))):
                state.timerSetting = nil
                return .none
            case .timerSetting(.presented(.delegate(.triggerTimer(let intTimer)))):
                state.isTimerRunning.toggle()
                state.count = intTimer * 60
                print("Here Int Timer \(intTimer)")
                if state.isTimerRunning{
                    return .run { send in
                        await send(.setTimer(intTimer * 60))
                        while true{
                            try await Task.sleep(for: .seconds(1))
                            await send(.timerTick)
                        }
                    }.cancellable(id: CancelID.timer)
                }else{
                    return .cancel(id: CancelID.timer)
                }
            case .timerSetting:
                return .none
            }
        }
        .ifLet(\.$timerSetting, action: \.timerSetting){
            TimerSettingFeature()
        }
    }
}
