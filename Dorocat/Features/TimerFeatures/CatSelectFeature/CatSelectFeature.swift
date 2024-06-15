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
        var catType: CatType = .doro
        var isProUser: Bool = true
        var tappedCatType: CatType = .doro
        var isLaunched:Bool = false
    }
    @Dependency(\.pomoSession) var session
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.store) var store
    @Dependency(\.pomoDefaults) var defaults
    enum Action:Equatable{
        case delegate(Delegate)
        case action(ControllType)
        case setProUser(Bool)
        case setCatType(CatType)
        case setSelectedCatType(CatType)
        case launchAction
        enum Delegate:Equatable{
            case cancel
            case setCatType(CatType)
        }
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .delegate: return .none
            case .action(let controllType):
                return viewAction(&state, controllType)
            case .launchAction:
                if !state.isLaunched{
                    print("Launch가 일어난다...")
                    state.isLaunched = true
                    return .run { send in
                        let isPro = store.isProUser
                        let selectedCat = await  defaults.selectedCat
                        await send(.setCatType(selectedCat))
                        await send(.setSelectedCatType(selectedCat))
                        await send(.setProUser(isPro))
                    }.merge(with: .run(operation: { send in
                        for await event in await store.eventAsyncStream(){
                            switch event{
                                case .userProUpdated(let value): await send(.setProUser(value))
                            }
                        }
                    }))
                }
                return .none
            case .setProUser(let isPro):
                state.isProUser = isPro
                return .none
            case .setCatType(let type):
                state.catType = type
                return .none
            case .setSelectedCatType(let type):
                state.tappedCatType = type
                return .none
            }
        }
    }
}
