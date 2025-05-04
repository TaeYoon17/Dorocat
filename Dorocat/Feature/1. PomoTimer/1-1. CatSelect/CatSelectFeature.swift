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
    @ObservableState struct State: Equatable {
        var catType: CatType = .doro
        var isProUser: Bool = true
        var tappedCatType: CatType = .doro
        var isLaunched:Bool = false
    }
    @Dependency(\.pomoSession) var session
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.store) var store
    @Dependency(\.doroStateDefaults) var doroStateDefaults
    enum Action:Equatable {
        case delegate(Delegate)
        case action(ControllType)
        case setProUser(Bool)
        case setCatType(CatType)
        case setSelectedCatType(CatType)
        case launchAction
        enum Delegate:Equatable {
            case cancel
            case setCatType(CatType)
        }
    }
    enum CancelID{ case purchase }
    var body: some ReducerOf<Self> {
        Reduce{ state, action in
            switch action {
            case .delegate: return .none
            case .action(let controllType):
                return viewAction(&state, controllType)
            case .launchAction:
                if !state.isLaunched {
                    state.isLaunched = true
                    return .run { send in
                        let isPro = store.isProUser
                        let selectedCat = await doroStateDefaults.getCatType()
                        await send(.setCatType(selectedCat))
                        await send(.setSelectedCatType(selectedCat))
                        await send(.setProUser(isPro))
                        if !isPro{
                            try await store.loadProducts()
                            await store.updatePurchasedProducts()
                        }
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
