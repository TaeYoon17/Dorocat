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
                    if catType == store.catType{
                        CatSelectStyle.ItemView(name: catType.rawValue.capitalized, imageThumbnail: catType.imageAssetName(type: .thumbnailLogo), isLocked: false)
                    }else{
                        CatSelectStyle.ItemView(name: catType.isAssetExist ? catType.rawValue.capitalized : "untitled", imageThumbnail: catType.isAssetExist ? catType.imageAssetName(type: .thumbnailInActiveLogo) : store.catType.imageAssetName(type: .thumbnailInActiveLogo), isLocked: true)
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

