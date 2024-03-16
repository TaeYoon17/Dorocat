//
//  AnalyzeView.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import SwiftUI
import ComposableArchitecture

struct AnalyzeView: View {
    @Perception.Bindable var store: StoreOf<AnalyzeFeature>
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    AnalyzeView(store: Store(initialState: AnalyzeFeature.State(), reducer: {
        AnalyzeFeature()
    }))
}
