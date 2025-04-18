//
//  PurchaseSheet.swift
//  Dorocat
//
//  Created by Developer on 4/22/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture
import StoreKit

enum PurchaseViewComponents{}

struct PurchaseSheet: View {
    @Bindable var store: StoreOf<SettingPurchaseFeature>
    var body: some View {
        VStack {
            PurchaseViewComponents.Information(store: store).padding(.bottom,31)
            HStack(spacing:20) {
                ForEach(CatType.allCases,id:\.self){ catType in
                    if catType == store.catType {
                        CatSelectStyle.ItemView(
                            name: catType.rawValue.capitalized,
                            imageThumbnail: catType.imageAssetName(type: .thumbnailLogo),
                            isActive: false,
                            isLocked: false
                        ) {
                            store.send(.doneTapped)
                        }
                    }else{
                        CatSelectStyle.ItemView(
                            name: catType.isAssetExist ? catType.rawValue.capitalized : "untitled",
                            imageThumbnail: catType.isAssetExist ? catType.imageAssetName(type: .thumbnailLogo) : store.catType.imageAssetName(type: .thumbnailLogo),isActive: false, isLocked: true
                        ) {
                            store.send(.doneTapped)
                        }
                    }
                }
            }.padding(.bottom,56)
            PurchaseViewComponents.OfferList(store:store).padding(.horizontal,16)
            Spacer()
            VStack(spacing: 16,content: {
                Button("Continue") {
                    store.send(.doneTapped)
                }.continueBtnStyle {
                    store.send(.doneWillTapped)
                }
                Button {
                    store.send(.restoreTapped)
                } label: {
                    Text("Restore Purchase").font(.paragraph03(.bold)).foregroundStyle(Color.grey02)
                }
            }).padding(.bottom,8)
        }
        .alert($store.scope(state: \.restoreAlert, action: \.restoreAlert))
        .refundRequestSheet(
            for: store.transactionID,
            isPresented: Binding(
                get: { store.isRefundPresent },
                set: { store.send(.setRefundPresent($0)) }
            )
        )
    }
}

