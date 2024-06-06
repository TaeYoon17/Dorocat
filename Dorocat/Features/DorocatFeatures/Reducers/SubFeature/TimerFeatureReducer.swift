//
//  TimerFeatureReducer.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture
extension DorocatFeature{
    func timerFeatureReducer(state: inout State,subAction action: TimerFeature.Action)->Effect<Action>{
        switch action{
        case .setGuideState(let guide):
            guard guide != state.guideState else {return .none}
            state.guideState = guide
            return .run{[guides = state.guideState] send in
                await self.guideDefaults.set(guide: guides)
            }
        case .setStatus(let status, count: _, startDate: _):
            switch status{
            case .focus,.breakTime:
                state.showPageIndicator = false
            default:
                state.showPageIndicator = true
            }
            return .none
        default: return .none
        }
    }
}
