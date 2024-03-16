//
//  SettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture
struct SettingView: View {
    var body: some View {
        WithPerceptionTracking{
            ScrollView {
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

#Preview {
    SettingView()
}
