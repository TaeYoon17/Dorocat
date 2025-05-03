//
//  PageMoveReducer.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture

extension DorocatFeature{
    func pageMoveReducer(state: inout State,type: PageType)->Effect<Action>{
        state.pageSelection = type
        let softImpact:Effect<Action> = .run{ send in await haptic.impact(style: .soft,intensity: 0.7)}
        switch type{
        case .analyze:
            if !state.guideState.goLeftFinished{
                state.guideState.goLeftFinished = true
                return .run{[guide = state.guideState] send in
                    await send(.setGuideStates(guide))
                }.merge(with: softImpact)
            }else{
                return softImpact
            }
        case .timer: return .run{send in await haptic.impact(style: .rigid,intensity: 0.7)}
        case .setting:
            if !state.guideState.goRightFinished{
                state.guideState.goRightFinished = true
                return Effect.merge(.run{[guide = state.guideState] send in
                    await send(.setGuideStates(guide))
                },softImpact)
            }else{
                return softImpact
            }
        }
    }
}
