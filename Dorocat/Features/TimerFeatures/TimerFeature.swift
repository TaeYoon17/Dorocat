//
//  TimerFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer struct TimerFeature{
    @ObservableState struct State: Equatable{
        var count = 0
        var isTimerRunning = false
    }
    enum Action{
        case stopTapped
        case timerTick
    }
    enum CancelID { case timer }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .stopTapped:
                state.isTimerRunning.toggle()
                return .none
            case .timerTick:
                state.count += 1
                return .none
            }
        }
    }
}
