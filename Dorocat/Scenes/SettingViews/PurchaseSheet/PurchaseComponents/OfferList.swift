//
//  OfferList.swift
//  Dorocat
//
//  Created by Developer on 6/1/24.
//

import SwiftUI
import ComposableArchitecture

extension PurchaseViewComponents{
    struct OfferList:View{
        let store: StoreOf<SettingPurchaseFeature>
        var body: some View{
            VStack {
                ForEach(store.products){ product in
                    OfferListItem(description: product.description == "" ? "Lifetime · Limited time offer"  : product.description, displayPrice: product.displayPrice)
                }
            }
        }
    }
    struct OfferListItem: View {
        let description:String
        let displayPrice: String
        var body: some View {
            HStack{
                VStack(alignment: .leading, spacing: 0) {
                    Text(description).foregroundStyle(.doroPink).font(.paragraph03(.bold))
                    Text(displayPrice)
                        .foregroundStyle(.doroWhite)
                        .font(.header04)
                        .frame(height: 40)
                }
                Spacer()
            }.padding(.horizontal,24)
                .padding(.vertical,21)
                .background(.grey03)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
