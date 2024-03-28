//
//  AddShoppingListScreen.swift
//  Dorocat
//
//  Created by Developer on 3/18/24.
//

import SwiftUI
import RealmSwift
import ComposableArchitecture

struct ShoppingListItemsScreen: View {
    @Perception.Bindable var store: StoreOf<ShoppingListItemFeature>
    @State var shoppingList:ShoppingListTable = .init()
    @State private var isPresented: Bool = false
    @State private var selectedItemIds: [ObjectId] = []
    @State private var selectedCategory: String = "All"
    
    var items: [ShoppingItem] {
        if(selectedCategory == "All") {
            return Array(shoppingList.items)
        } else {
            return shoppingList.items.sorted(byKeyPath: "title")
                .filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        VStack {
            CategoryFilterView(selectedCategory: $selectedCategory)
                .padding()
            if items.isEmpty {
                Text("No items found.")
            }
            
            List {
                ForEach(items) { item in
                    NavigationLink {
//                        AddShoppingListItemScreen(shoppingList: shoppingList, itemToEdit: item)
                        Text("Hello world")
                    } label: {
                        ShoppingItemCell(item: item, selected: selectedItemIds.contains(item.id)) { selected in
                            if selected {
                                selectedItemIds.append(item.id)
                                if let indexToDelete = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
                                    // delete the item
                                    $shoppingList.items.remove(at: indexToDelete)
                                }
                            }
                        }
                    }
                    
                  
                }.onDelete(perform: $shoppingList.items.remove)
            }
            
            .navigationTitle(shoppingList.title)
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // action
                    isPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
//        .sheet(isPresented: $isPresented) {
//            AddShoppingListItemScreen(store: <#StoreOf<AddShoppingListFeature>#>, shoppingList: shoppingList)
//        }
    }
}

//struct ShoppingListItemsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ShoppingListItemsScreen(shoppingList: ShoppingList())
//        }
//    }
//}
