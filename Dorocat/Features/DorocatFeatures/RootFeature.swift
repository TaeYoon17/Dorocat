//
//  RootFeature.swift
//  Dorocat
//
//  Created by Greem on 4/18/25.
//

import Foundation
import ComposableArchitecture

/// 하나의 단일 네비게이션으로 관리하게 된다...
@Reducer
struct RootFeature {
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            // 존재하지 않으면 생성한다.
            case registerDoroScene(DorocatFeature.State = .init())
        }
        
        enum Action {
            case doro(DorocatFeature.Action)
        }
        
        
        var body: some ReducerOf<Self> {
            Scope(state: \.registerDoroScene, action: \.doro) {
                DorocatFeature()
            }
        }
    }
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path(let pathAction):
                switch pathAction {
                case .element(id: _, action: .doro(.initialAction)):
                    state.path.append(.registerDoroScene())
                    return .none
                default:
                    return .none
                }
            }
        }
        .forEach(\.path, action: \.path) { }
    }
}
