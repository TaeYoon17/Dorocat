//
//  ControllReducer>Haptic.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture
extension CatSelectFeature.ControllReducers{
    struct HapticReducer:CatSelectControllerProtocol{
        @Dependency(\.haptic) var haptic
        func itemTapped(state: inout CatSelectFeature.State,catType:CatType) -> Effect<CatSelectFeature.Action> {
            return .run { send in
                await haptic.impact(style: .soft)
            }
        }
        
        func doneTapped(state: inout CatSelectFeature.State) -> Effect<CatSelectFeature.Action> {
            return .run { send in
                await haptic.impact(style: .soft)
            }
        }
    }
}
