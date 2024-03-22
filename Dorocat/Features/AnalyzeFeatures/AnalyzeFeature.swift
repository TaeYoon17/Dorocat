//
//  AnalyzeFeature.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift
@Reducer struct AnalyzeFeature{
    @ObservableState struct State:Equatable{
        @Presents var addShoppingList:AddShoppingListFeature.State?
        var shoppingLists: [ShoppingList] = []
        var path = StackState<ShoppingListItemFeature.State>()
    }
    enum Action: Equatable{
        case openShoppingListTapped
        case addShoppingListTapped
        case initShoppingLists
        case updateShoppingLists([ShoppingList])
        case path(StackAction<ShoppingListItemFeature.State,ShoppingListItemFeature.Action>)
        case addShoppingList(PresentationAction<AddShoppingListFeature.Action>)
    }
    @Dependency(\.numbersAPIClient) var apiClient
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .openShoppingListTapped:
                return .none
            case .addShoppingListTapped:
                state.addShoppingList = AddShoppingListFeature.State()
                return .none
            case .path:
                return .none
//            case .addShoppingList(.presented(.delegate(.appendShoppingListCompleted))): return .none
            case .initShoppingLists:
                return .run { send in
                    do{
                        let rawList = try await apiClient.getShoppingLists()
                        await send(.updateShoppingLists(rawList))
                    }catch{
                        fatalError("get error!!")
                    }
                }
            case .updateShoppingLists(let list):
                state.shoppingLists = list
                return .none
            case .addShoppingList:
                return .none
            }
        }.forEach(\.path, action: \.path){
            ShoppingListItemFeature()
        }
        .ifLet(\.$addShoppingList, action: \.addShoppingList){
            AddShoppingListFeature()
        }
    }
}
