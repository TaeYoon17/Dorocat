//
//  AddShoppingListFeature.swift
//  Dorocat
//
//  Created by Developer on 3/22/24.
//

import Foundation
import ComposableArchitecture
/*
@Reducer struct AddShoppingListFeature{
    @ObservableState struct State: Equatable{
        var selectedCategory:String = ""
        var title:String = ""
        var address:String = ""
    }
    enum Action: Equatable{
        case addShoppingListTapped
        case setTitle(String)
        case setAddress(String)
        case delegate(Delegate)
        enum Delegate: Equatable{
            case appendShoppingListCompleted
        }
    }
    @Dependency(\.dismiss) var dismiss
    @DBActor @Dependency(\.dbAPIClients) var api
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .setTitle(let title):
                state.title = title
                return .none
            case .setAddress(let address):
                state.address = address
                return .none
            case .addShoppingListTapped:
                let shoppingList = ShoppingListTable()
                shoppingList.title = state.title
                shoppingList.address = state.address
                state.title = ""
                state.address = ""
                return .run { send in
                    do{
                        try await api.appendShoppingList(shoppingList)
                    }catch{
                        print("append shoppinglist error")
                    }
                    await send(.delegate(.appendShoppingListCompleted))
                    await self.dismiss()
                }
            case .delegate: return .none
            }
        }
    }
}
*/
