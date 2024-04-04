//
//  SettingTitleView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import ComposableArchitecture
struct SettingTitleView: View {
    var body: some View {
        HStack {
            Text("Meow...")
                .foregroundStyle(.white)
                .font(.header02)
            Spacer()
        }.frame(height: 48)
    }
}
#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}
