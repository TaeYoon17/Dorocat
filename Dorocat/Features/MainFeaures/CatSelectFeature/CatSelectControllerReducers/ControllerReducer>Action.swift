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
        typealias CancelID = CatSelectFeature.CancelID
        @Dependency(\.dismiss) var dismiss
        @Dependency(\.pomoDefaults) var defaults
        @Dependency(\.cat) var cat
        @Dependency(\.store) var store
        
        func itemTapped(state: inout CatSelectFeature.State,catType:CatType) -> Effect<CatSelectFeature.Action> {
            state.tappedCatType = catType
            return .none
        }
        
        func doneTapped(state: inout CatSelectFeature.State) -> Effect<CatSelectFeature.Action> {
            if state.isProUser && state.tappedCatType != state.catType {
                return .run {[selectedType = state.tappedCatType] send in
                    await defaults.setCatType(selectedType)
                    await send(.delegate(.setCatType(selectedType)))
                    await cat.updateCatType(selectedType)
                    await dismiss()
                }
            }
            return .run { send in await dismiss() }
        }
    }
}
