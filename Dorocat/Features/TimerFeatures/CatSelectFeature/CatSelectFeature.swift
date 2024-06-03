//
//  CatSelectFeature.swift
//  Dorocat
//
//  Created by Developer on 5/31/24.
//

import Foundation
import ComposableArchitecture
@Reducer
struct CatSelectFeature{
    @ObservableState struct State: Equatable{
        var selectedSession:SessionItem = .init(name: "")
        var sessions:[SessionItem] = []
        var catType: CatType = .doro
        var isProUser: Bool = true
        var tappedCatType: CatType = .doro
    }
    @Dependency(\.pomoSession) var session
    @Dependency(\.dismiss) var dismiss
    enum Action:Equatable{ // 키패드 접근을 어떻게 할 것인지...
        case delegate
        case action(ControllType)
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .delegate: return .none
            case .action(let controllType):
                return viewAction(&state, controllType)
            }
        }
    }
}
