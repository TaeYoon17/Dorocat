//
//  SettingPurchaseFeature.swift
//  Dorocat
//
//  Created by Developer on 4/22/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingPurchaseFeature{
    @ObservableState struct State: Equatable{
        var hello:String = "Hello world"
    }
    enum Action:Equatable{
        case doneTapped
        enum Delegate: Equatable{
            case cancel
        }
    }
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .doneTapped:
                return .none
            }
        }
    }
}
