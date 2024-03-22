//
//  AddShoppingListItemScreen.swift
//  Dorocat
//
//  Created by Developer on 3/18/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift

struct AddShoppingListItemScreen: View {
    @Perception.Bindable var store: StoreOf<AddShoppingListFeature>
    //    @ObservedRealmObject var shoppingList: ShoppingList = .init()
    var itemToEdit: ShoppingItem?
    
    @Environment(\.dismiss) private var dismiss
    
    
    
    private var isEditing: Bool {
        itemToEdit == nil ? false: true
    }
    
    var body: some View {
        WithPerceptionTracking{
            
            Form {
                TextField("Enter title", text: $store.title.sending(\.setTitle))
                TextField("Enter address", text: $store.address.sending(\.setAddress))
                Button {
                    // create a shopping list record
                    store.send(.addShoppingListTapped)
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.bordered)
                
            }
            .navigationTitle("New List")
            
        }
    }
}

//struct AddShoppingListItemScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        AddShoppingListItemScreen(shoppingList: ShoppingList())
//    }
//}
