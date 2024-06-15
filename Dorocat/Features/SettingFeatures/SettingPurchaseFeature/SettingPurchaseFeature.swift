//
//  SettingPurchaseFeature.swift
//  Dorocat
//
//  Created by Developer on 4/22/24.
//

import Foundation
import ComposableArchitecture
import StoreKit
@Reducer
struct SettingPurchaseFeature{
    @ObservableState struct State: Equatable{
        var products:[Product] = []
        var isInit = false
        var catType: CatType = .doro
        var isRefundPresent:Bool = false
        var transactionID:Transaction.ID = 0
    }
    enum Action:Equatable{
        case doneWillTapped
        case doneTapped
        case initAction
        case setProducts([Product])
        case setRefundPresent(Bool)
        case setTransactionID(Transaction.ID)
        enum Delegate: Equatable{
            case cancel
        }
    }
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.store) var store
    @Dependency(\.haptic) var haptic
    enum CancelID{
        case purchase
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .initAction:
                if !state.isInit{
                    state.isInit = true
                    return .run { send in
                        try await store.loadProducts()
                        await send(.setProducts(store.products))
                        await store.updatePurchasedProducts()
                        await send(.setTransactionID(store.refundTransactionID))
                        for await event in await store.eventAsyncStream(){
                            switch event{
                            case .userProUpdated(let isUpdated):
                                if isUpdated{ await dismiss() }
                            }
                        }
                    }
                }
                return .none
            case .doneTapped:
                return .run{ send in
                    try await store.purchase()
                }
                .cancellable(id: CancelID.purchase)
            case .setProducts(let products):
                state.products = products
                return .none
            case .doneWillTapped:
                return .run { send in
                    await haptic.impact(style: .soft)
                }
            case .setRefundPresent(let isPresent):
                state.isRefundPresent = isPresent
                return .none
            case .setTransactionID(let id): 
                state.transactionID = id
                return .none
            }
        }
    }
}
