//
//  CatSelectView.swift
//  Dorocat
//
//  Created by Developer on 5/31/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture
enum CatSelectViewComponents{}
 
struct CatSelectView: View {
    @Bindable var store: StoreOf<CatSelectFeature>
    var body: some View {
        VStack(spacing:0,content: {
            CatSelectViewComponents.Info(store: store)
                .padding(.bottom,42)
            CatSelectViewComponents.CatList(store: store)
            Spacer()
            CatSelectViewComponents.ConfirmBtn(store: store)
        })
        .onAppear{ store.send(.launchAction) }
        .clipShape(.rect(topLeadingRadius: 24,
                         bottomLeadingRadius: 0,
                         bottomTrailingRadius: 0,
                         topTrailingRadius: 24,
                         style: .circular))
        .padding(.top,40).padding(.bottom,26)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

//#Preview {
//    CatSelectView()
//}
