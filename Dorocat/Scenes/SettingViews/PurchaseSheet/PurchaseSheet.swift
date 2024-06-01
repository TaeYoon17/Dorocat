//
//  PurchaseSheet.swift
//  Dorocat
//
//  Created by Developer on 4/22/24.
//

import SwiftUI
import ComposableArchitecture
enum PurchaseViewComponents{}
struct PurchaseSheet: View {
    @Bindable var store: StoreOf<SettingPurchaseFeature>
    var body: some View {
        VStack(spacing:0) {
            PurchaseViewComponents.Information(store: store)
            HStack(spacing:20) {
                ForEach(CatType.allCases,id:\.self){ catType in
                    CatListItem(catType: catType,isActive: catType == store.catType) {
                        print("이건 뭘까...")
                    }
                }
            }.padding(.bottom,56)
            PurchaseViewComponents.OfferList().padding(.horizontal,16)
            Spacer()
            VStack(spacing: 16,content: {
                Button("Continue") {
                    store.send(.doneTapped)
                }.continueBtnStyle {
                    store.send(.doneWillTapped)
                }
                Button {
                } label: {
                    Text("Restore Purchase").font(.paragraph03(.bold)).foregroundStyle(.grey02)
                }
            })
        }
    }
}

