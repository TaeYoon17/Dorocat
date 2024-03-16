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
            TabView(selection: $store.pageSelection.sending(\.pageMove), content:  {
                AnalyzeView(store: self.store.scope(state: \.anylzeState, action: \.analyze))
//                    .tabItem { Label(
//                        title: { Text("Analyze") },
//                        icon: { Image(systemName: "42.circle") }
//                    ) }
                    .tag(DorocatFeature.PageType.analyze)
                // 슬라이딩마다 부모 Store에서 저장한 값을 가져온다!!
                TimerView(store: store.scope(state: \.timerState, action: \.timer))
                    .tag(DorocatFeature.PageType.timer)
                SettingView(store: self.store.scope(state: \.settingState, action: \.setting))
//                    .tabItem { Label("Setting", systemImage: "42.circle") }
                    .tag(DorocatFeature.PageType.setting)
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
}

//#Preview {
//    DoroMainView()
//}
