//
//  DoroView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture
struct DoroMainView: View {
    @Perception.Bindable var store: StoreOf<DorocatFeature>
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: .init(get: { store.pageSelection }, set: { store.send(.pageMove($0)) }), content:  {
                Text("Analyze").tag(DorocatFeature.PageType.analyze)
                TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
                    TimerFeature()
                })).tag(DorocatFeature.PageType.timer)
                SettingView().tag(DorocatFeature.PageType.setting)
            }).tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
}

//#Preview {
//    DoroMainView()
//}
