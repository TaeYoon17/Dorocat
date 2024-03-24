//
//  SettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture
struct SettingView: View {
    @Perception.Bindable var store: StoreOf<SettingFeature>
    var body: some View {
        WithPerceptionTracking{
            NavigationStack {
                ZStack{
                    Color.grey04
                    ScrollView {
                        VStack{
                            Text("Settings")
                            Text("Memebership")
                            Text("Add a widget")
                            Text("Sound")
                            Text("Haptics")
                            Text("Support")
                            Text("Rate app")
                        }
                    }
                }
            }
                .tint(.black)
                    .foregroundStyle(.black)
                    .toolbar(.hidden, for: .navigationBar)
                    .background(.grey04)
        }
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}

