//
//  iCloudSyncFeature+ReducerExtensions.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation
import ComposableArchitecture

extension ICloudSyncFeature {
    func viewAction(state: inout State, act: ViewActionType) -> Effect<Action> {
        Controller.makeAllReducers(state: &state, act: act)
    }
}
