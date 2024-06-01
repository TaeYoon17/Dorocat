//
//  Info.swift
//  Dorocat
//
//  Created by Developer on 6/1/24.
//

import SwiftUI
import ComposableArchitecture

extension CatSelectViewComponents{
    struct Info:View {
        let store: StoreOf<CatSelectFeature>
        var body: some View {
            VStack(alignment:.center) {
                Image(store.catType.imageAssetName(type: .mainLogo))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 120, height: 120, alignment: .center)
                Text(store.catType.rawValue.capitalized)
                    .multilineTextAlignment(.center)
                    .font(.header04)
                    .foregroundStyle(.doroWhite)
                Text(store.catType.desc).font(.paragraph03())
                    .foregroundStyle(.grey01)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
