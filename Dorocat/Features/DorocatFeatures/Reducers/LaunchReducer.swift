//
//  LaunchReducer.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture
extension DorocatFeature{
    func launchReducer(state:inout State) -> Effect<Action>{
        if !state.isAppLaunched{
            state.isAppLaunched = true
            state.guideState.onBoarding = true
            return Effect.merge(.run{ send in
                let guides = await self.guideDefaults.get()
                await send(.setGuideStates(guides))
                await send(.timer(.setGuideState(guides)))
            },.run(operation: { send in
                if await !initial.isUsed{
                    await initial.offInitial()
                    await send(.initialAction)
                }
            }),.run{ send in
                try! await session.initAction()
            })
        }else{
            return .none
        }
    }
}