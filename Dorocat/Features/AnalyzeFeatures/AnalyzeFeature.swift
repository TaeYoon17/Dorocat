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
        var shoppingLists: IdentifiedArrayOf<ShoppingList> = []
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
    @DBActor @Dependency(\.dbAPIClients) var apiClient
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
            case .addShoppingList(.presented(.delegate(.appendShoppingListCompleted))):
                return .run { send in
//                    var li:[ShoppingList] = []
//                    for v in await apiClient.getShoppingLists(){
//                        await li.append(ShoppingList(table: v))
//                    }
                    let li = await apiClient.getShoppingLists().asyncMap{ 
                        await ShoppingList(table: $0)
                    }
                    await send(.updateShoppingLists(li))
                }
            case .initShoppingLists:
                return .run {@DBActor send in
                    do{
                        try await apiClient.initRealm()
                        let list = apiClient.getShoppingLists().map{ShoppingList(table: $0)}
                        await send(.updateShoppingLists(list))
                    }catch{
                        fatalError("get error!!")
                    }
                }
            case .updateShoppingLists(let list):
                state.shoppingLists.removeAll()
                state.shoppingLists.append(contentsOf: list)
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
extension Sequence{
    func asyncMap<T>(_ transform: (Element) async throws -> T ) async rethrows -> [T]{
        var values = [T]()
        for element in self{
            try await values.append(transform(element))
        }
        return values
    }
}
