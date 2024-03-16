//
//  DorocatFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DorocatFeature{
    enum PageType: Equatable,Hashable,CaseIterable{
        case analyze
        case timer
        case setting
    }
    @ObservableState struct State: Equatable{
        var pageSelection: PageType = .timer
    }
    enum Action{
        case pageMove(PageType)
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .pageMove(let type):
                state.pageSelection = type
                return .none
            }
        }
    }
}

extension DorocatFeature{
    @Reducer(state: .equatable) enum Destination{
    }
}
