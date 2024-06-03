//
//  ControllerReducer>Action.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import Foundation
import ComposableArchitecture

extension CatSelectFeature.ControllReducers{
    struct ActionReducer:CatSelectControllerProtocol{
        typealias Action = CatSelectFeature.Action
        @Dependency(\.pomoDefaults) var defaults
        func itemTapped(state: inout CatSelectFeature.State,catType:CatType) -> Effect<CatSelectFeature.Action> {
            state.catType = catType
            return .none
        }
        
        func doneTapped(state: inout CatSelectFeature.State) -> Effect<CatSelectFeature.Action> {
            return .none
        }
    }
}
