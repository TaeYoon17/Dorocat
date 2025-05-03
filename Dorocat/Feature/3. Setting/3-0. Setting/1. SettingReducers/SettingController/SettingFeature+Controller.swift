//
//  SettingFeature+Controller.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation
import ComposableArchitecture


extension SettingFeature {
    enum Controller: CaseIterable {
        case action, haptic
        
        private var reducer: SettingControllerProtocol {
            switch self {
            case .action: ActionReducer()
            case .haptic: HapticReducer()
            }
        }
        
        static func makeAllReducers(state: inout SettingFeature.State, act: ViewActionType) -> Effect<Action> {
            let hapticReducer = Self.haptic.reducer.makeReducer(state: &state, act: act)
            let mergeEffect: Effect<Action> = .merge(
                [Self.action].map { $0.reducer.makeReducer(state: &state, act: act) }
            )
            return Effect.concatenate(mergeEffect, hapticReducer)
        }
    }
}


