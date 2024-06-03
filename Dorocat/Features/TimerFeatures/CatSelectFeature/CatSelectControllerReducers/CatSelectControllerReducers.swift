//
//  CatControllerReducers.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import Foundation
import ComposableArchitecture
extension CatSelectFeature{
    func viewAction(_ state:inout State,_ act: ControllType) -> Effect<Action>{
        return ControllReducers.makeAllReducers(state: &state, act: act)
    }
}
protocol CatSelectControllerProtocol{
    func makeReducer(state: inout CatSelectFeature.State,
                     act:CatSelectFeature.ControllType) -> Effect<CatSelectFeature.Action>
    func itemTapped(state: inout CatSelectFeature.State,catType:CatType) -> Effect<CatSelectFeature.Action>
    func doneTapped(state: inout CatSelectFeature.State) -> Effect<CatSelectFeature.Action>
    
}
extension CatSelectControllerProtocol{
    func makeReducer(state: inout CatSelectFeature.State,
                     act:CatSelectFeature.ControllType) -> Effect<CatSelectFeature.Action>{
        switch act {
        case .itemTapped(let item):
            itemTapped(state: &state,catType:item)
        case .doneTapped:
            doneTapped(state: &state)
        }
    }
}
extension CatSelectFeature{
    enum ControllReducers:CaseIterable{
        case action
        private var myReducer: CatSelectControllerProtocol{
            switch self{
            case .action: ActionReducer()
            }
        }
        static func makeAllReducers(state: inout State,act: ControllType) -> Effect<Action>{
            return Effect.concatenate(Self.action.myReducer.makeReducer(state: &state, act: act))
        }
    }

    
}

