//
//  SettingTitleView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

struct SettingTitleView: View {
    var body: some View {
        HStack {
            Text("Meow...")
                .foregroundStyle(Color.doroWhite)
                .font(.header03)
                .fontCoordinator()
            Spacer()
        }.frame(height: 48)
    }
}
#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}
