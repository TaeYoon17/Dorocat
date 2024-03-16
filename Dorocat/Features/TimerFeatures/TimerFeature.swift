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
        var count = 0
        var isTimerRunning = false
//        @Presents var timerSetting: 
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
