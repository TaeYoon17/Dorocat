//
//  PurchaseSheet.swift
//  Dorocat
//
//  Created by Developer on 4/22/24.
//

import SwiftUI
import ComposableArchitecture
struct PurchaseSheet: View {
    @Bindable var store: StoreOf<SettingPurchaseFeature>
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(content: {
                    ForEach(store.products){ product in
                        Text(product.displayName)
                    }
                }).padding()
                    .background(.doroWhite)
            }
            Button {
                store.send(.doneTapped)
            } label: {
                Text("Continue")
                    .font(.button)
                    .padding(.horizontal,28)
                    .padding(.vertical,19.5)
                    .background(.doroPink)
                    .clipShape(Capsule())
            }
        }
    }
}

