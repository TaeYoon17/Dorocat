//
//  ReducerExtensions.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation
import ComposableArchitecture

extension SettingFeature {
    func viewAction(_ state:inout State, _ act: ViewActionType) -> Effect<Action> {
        return Controller.makeAllReducers(state: &state, act: act)
    }
}
