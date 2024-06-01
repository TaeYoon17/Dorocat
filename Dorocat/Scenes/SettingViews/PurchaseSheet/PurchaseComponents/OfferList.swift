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
        var body: some View{
            VStack {
                OfferListItem()
            }
        }
    }
    struct OfferListItem: View {
        var body: some View {
            HStack{
                VStack(alignment: .leading, spacing: 0) {
                    Text("Lifetime · Limited time offer").foregroundStyle(.doroPink).font(.paragraph03(.bold))
                    Text("$3.99")
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
