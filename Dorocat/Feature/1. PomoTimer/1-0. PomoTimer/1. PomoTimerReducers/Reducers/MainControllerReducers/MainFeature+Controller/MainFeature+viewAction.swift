//
//  MainFeature+viewAction.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
extension PomoTimerFeature{
    func viewAction(_ state:inout State,_ act: ControllType) -> Effect<Action>{
        return Controller.makeAllReducers(state: &state, act: act)
    }
}

