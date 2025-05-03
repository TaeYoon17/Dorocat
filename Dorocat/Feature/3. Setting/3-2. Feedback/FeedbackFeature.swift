//
//  FeedbackFeature.swift
//  Dorocat
//
//  Created by Developer on 6/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FeedbackFeature{
    @ObservableState struct State: Equatable{}
    @Dependency(\.dismiss) var dismiss
    enum Action:Equatable{
        case delegate
        case close
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .delegate: return .none
            case .close:
                return .run { send in
                    await dismiss()
                }
            }
        }
    }
}
