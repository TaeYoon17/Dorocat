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
            ZStack(alignment: .top) {
                TabView(selection: $store.pageSelection.sending(\.pageMove), content:  {
                    AnalyzeView(store: self.store.scope(state: \.anylzeState, action: \.analyze))
                        .tag(DorocatFeature.PageType.analyze)
                        .tabItem({
                            Label("analyze", systemImage: "pencil.circle").tint(.black)
                        })
                    // 슬라이딩마다 부모 Store에서 저장한 값을 가져온다!!
                    TimerView(store: store.scope(state: \.timerState, action: \.timer))
                        .tag(DorocatFeature.PageType.timer)
                        .tabItem({
                            Label("Timer",systemImage: "folder.circle").tint(.black)
                        })
                    
                    SettingView(store: self.store.scope(state: \.settingState, action: \.setting))
                        .background(.grey04)
                        .tag(DorocatFeature.PageType.setting)
                        .tabItem({
                            Label("Setting",systemImage: "paperplane").tint(.black)
                        })
                })
                .tabViewStyle(.page(indexDisplayMode: .always))
                .ignoresSafeArea(.container,edges: .bottom)
                Text("one two three")
            }
            .background(.grey04)
        }
    }
    
}

//#Preview {
//    DoroMainView()
//}
