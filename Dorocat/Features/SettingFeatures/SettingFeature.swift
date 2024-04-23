//
//  SettingFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer struct SettingFeature{
    @ObservableState struct State: Equatable{
        var isSound = false
        @Presents var purchaseSheet: SettingPurchaseFeature.State?
    }
    enum Action:Equatable{ 
        case setSound(Bool)
        case purchaseSheet(PresentationAction<SettingPurchaseFeature.Action>)
        case openPurchase
    }
    var body: some ReducerOf<Self>{
        Reduce{ state,action in
            switch action{
            case .setSound(let sound):
                print("wow world!!")
                state.isSound = sound
                return .none
            case .purchaseSheet: return .none
            case .openPurchase:
                state.purchaseSheet = .init()
                return .run{ send in
                    await send(.purchaseSheet(.presented(.doneTapped)))
                }
            }
        }
        .ifLet(\.$purchaseSheet, action: \.purchaseSheet){
            SettingPurchaseFeature()
        }
    }
}
