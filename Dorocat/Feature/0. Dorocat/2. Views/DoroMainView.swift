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
            if store.showPageIndicator {
                self.tabView
                    .ignoresSafeArea(.container, edges: .bottom)
                    .alert($store.scope(state: \.alert, action: \.alert))
                PageIndicatorView(
                    itemCount: DorocatFeature.PageType.allCases,
                    selectedIndex: store.pageSelection
                )
            } else {
                PomoTimerView(store: store.scope(state: \.timerState, action: \.timer))
                    .tag(DorocatFeature.PageType.timer)
                    .tabItem {
                        Label("Timer",systemImage: "folder.circle").tint(.doroBlack)
                    }
            }
            /// 온보딩 상태이다.
            if !store.guideState.onBoardingFinished {
                OnboardingView(store: store)
            }
        }
    }
    
    @ViewBuilder
    var tabView: some View {
        TabView(selection: $store.pageSelection.sending(\.pageMove), content:  {
            AnalyzeView(store: self.store.scope(state: \.anylzeState, action: \.analyze))
                .tag(DorocatFeature.PageType.analyze)
                .tabItem({
                    Label(Constant.TapType.analyze, systemImage: Constant.TapLogo.analyze).tint(.doroBlack)
                })
                
            // 슬라이딩마다 부모 Store에서 저장한 값을 가져온다!!
            PomoTimerView(store: store.scope(state: \.timerState, action: \.timer))
                .tag(DorocatFeature.PageType.timer)
                .tabItem {
                    Label(Constant.TapType.pomoTimer, systemImage: Constant.TapLogo.pomoTimer).tint(.doroBlack)
                }
                

            SettingView(store: self.store.scope(state: \.settingState, action: \.setting))
                .tag(DorocatFeature.PageType.setting)
                .tabItem {
                    Label(Constant.TapType.setting, systemImage: Constant.TapLogo.setting).tint(.doroBlack)
                }
        })
        .tabViewStyle(.page(indexDisplayMode: .never))
        
    }
}

