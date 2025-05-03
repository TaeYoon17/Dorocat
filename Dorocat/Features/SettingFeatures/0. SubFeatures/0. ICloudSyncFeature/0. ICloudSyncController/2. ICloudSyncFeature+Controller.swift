//
//  ICloudSyncFeature+Controller.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation
import ComposableArchitecture

extension ICloudSyncFeature {
    enum Controller: CaseIterable {
        case action
        case haptic
        
        var reducer: ICloudSyncControllerProtocol {
            switch self {
            case .haptic: HapticReducer()
            case .action: ActionReducer()
            }
        }
        
        static func makeAllReducers(
            state: inout ICloudSyncFeature.State,
            act: ViewActionType
        ) -> Effect<Action> {
            let allReducers = [Self.action, .haptic].map {
                $0.reducer.makeReducer(state: &state, act: act)
            }
            return .merge(allReducers)
        }
    }
}
