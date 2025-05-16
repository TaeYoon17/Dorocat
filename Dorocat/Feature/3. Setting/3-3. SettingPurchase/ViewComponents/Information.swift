//
//  Info.swift
//  Dorocat
//
//  Created by Developer on 6/1/24.
//

import SwiftUI
import ComposableArchitecture
extension PurchaseViewComponents{
    struct Information:View {
        let store: StoreOf<SettingPurchaseFeature>
        var body: some View {
            VStack(spacing:0) {
                LottieView(fileName: store.catType.lottieAssetName(type: .sleeping), loopMode: .playOnce).frame(width: 180,height:180)
                titleView
                descView
            }
        }
        var titleView:some View{
            (Text("Dorocat ").foregroundStyle(Color.doroWhite) + Text("Purrs").foregroundStyle(Color.doroPink))
                .font(.header04)
        }
        var descView: some View{
            Text("Unlock all the adorable cats!\nAnd Stay tuned for the new cats.").foregroundStyle(Color.grey01).font(.paragraph03()).multilineTextAlignment(.center)
        }
    }
}
