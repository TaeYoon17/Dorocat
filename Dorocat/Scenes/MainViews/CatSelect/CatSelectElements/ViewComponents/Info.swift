//
//  Info.swift
//  Dorocat
//
//  Created by Developer on 6/1/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

extension CatSelectViewComponents{
    struct Info:View {
        let store: StoreOf<CatSelectFeature>
        var body: some View {
            VStack(alignment:.center) {
                Image(store.tappedCatType.imageAssetName(type: .mainLogo))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 120, height: 120, alignment: .center)
                Text(store.tappedCatType.rawValue.capitalized)
                    .multilineTextAlignment(.center)
                    .font(.header04)
                    .foregroundStyle(Color.doroWhite)
                Text(store.tappedCatType.desc).font(.paragraph03())
                    .foregroundStyle(Color.grey01)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
