//
//  DoroView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

struct DoroMainView: View {
    @Bindable var store: StoreOf<DorocatFeature>
    var body: some View {
        ZStack(alignment: .top) {
            if store.showPageIndicator{
                TabView(selection: $store.pageSelection.sending(\.pageMove), content:  {
                    AnalyzeView(store: self.store.scope(state: \.anylzeState, action: \.analyze))
                        .tag(DorocatFeature.PageType.analyze)
                        .tabItem({
                            Label("analyze", systemImage: "pencil.circle").tint(.doroBlack)
                        })
                    // 슬라이딩마다 부모 Store에서 저장한 값을 가져온다!!
                    MainView(store: store.scope(state: \.timerState, action: \.timer))
                        .tag(DorocatFeature.PageType.timer)
                        .tabItem({
                            Label("Timer",systemImage: "folder.circle").tint(.doroBlack)
                        })
                        
                    SettingView(store: self.store.scope(state: \.settingState, action: \.setting))
                        .tag(DorocatFeature.PageType.setting)
                        .tabItem({
                            Label("Setting",systemImage: "paperplane").tint(.doroBlack)
                        })
                })
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(.container,edges: .bottom)
                PageIndicatorView(itemCount: DorocatFeature.PageType.allCases,selectedIndex: store.pageSelection)
            }else{
                MainView(store: store.scope(state: \.timerState, action: \.timer))
                    .tag(DorocatFeature.PageType.timer)
                    .tabItem({
                        Label("Timer",systemImage: "folder.circle").tint(.doroBlack)
                    })
                    .ignoresSafeArea(.container,edges: .bottom)
            }
            if !store.guideState.onBoarding{
                OnboardingView(store: store)
            }
        }
    }
    
}

//#Preview {
//    DoroMainView()
//}
