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
    }
    enum Action:Equatable{ 
        case setSound(Bool)
    }
    var body: some ReducerOf<Self>{
        Reduce{ state,action in
            switch action{
            case .setSound(let sound):
                print("wow world!!")
                state.isSound = sound
                return .none
            }
        }
    }
}
