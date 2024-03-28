//
//  AnalyzeView.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift
struct AnalyzeView: View {
    @Perception.Bindable var store: StoreOf<AnalyzeFeature>
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path,action: \.path)) {
                List {
                    Section {
                        HStack {
                            Text("Append Shopping Lists")
                            Spacer()
                            Button {
                                self.store.send(.addShoppingListTapped)
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    Section {
                        ForEach(store.shoppingLists, id: \.id) { shoppingList in
                            NavigationLink(state: ShoppingListItemFeature.State()) {
                                VStack(alignment: .leading) {
                                    Text(shoppingList.title)
                                    Text(shoppingList.address)
                                        .opacity(0.4)
                                }
                            }
                        }
//                        .onDelete(perform: $shoppingLists.remove)
                    }
                }
                .onAppear(){
                        self.store.send(.initShoppingLists)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            self.store.send(.addShoppingListTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationTitle("Analyze Title")
                .toolbar(.hidden, for: .navigationBar)
            } destination: { store in
                ShoppingListItemsScreen(store: store)
            }.sheet(item: $store.scope(state: \.addShoppingList, action: \.addShoppingList), content: { addShoppingListStore in
                NavigationStack {
                    AddShoppingListItemScreen(store: addShoppingListStore)
                }
            })
        }
    }
}

#Preview {
    AnalyzeView(store: Store(initialState: AnalyzeFeature.State(), reducer: {
        AnalyzeFeature()
    }))
}
