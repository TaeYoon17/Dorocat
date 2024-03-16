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
            VStack(content: {
                HStack(content: {
                    Text(store.timer).font(.largeTitle)
                })
                Button{
                    store.send(.goTimerSetting)
                }label: {
                    Text("Go to timer setting")
                }
                Button(action: {
                    store.send(.stopTapped)
                }, label: {
                    Text("Stop")
                })
            }).sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                NavigationStack {
                    TimerSettingView(store: timerSettingStore)
                }
            }
        }
    }
}

#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}
