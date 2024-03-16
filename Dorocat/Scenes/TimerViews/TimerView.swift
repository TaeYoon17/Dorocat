//
//  TimerView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture

struct TimerView: View {
    @Perception.Bindable var store: StoreOf<TimerFeature>
    var body: some View {
        WithPerceptionTracking{
            Button {
                print("Hello world")
            } label: {
                Text("Hello world!!")
            }
        }
    }
}

#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}
