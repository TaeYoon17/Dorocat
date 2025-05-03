//
//  TimerViewModifiers.swift
//  Dorocat
//
//  Created by Developer on 4/6/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

enum TimerViewModifiers{
    enum Guide{
        struct GoLeft:ViewModifier{
            let store: StoreOf<MainFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment: .leading) {
                    if store.timerProgressEntity.status == .standBy && !store.guideInformation.goLeft{
                        TimerViewComponents.Guide.GoLeft()
                    }
                }
            }
        }
        struct GoRight: ViewModifier{
            let store: StoreOf<MainFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment: .trailing) {
                    if store.timerProgressEntity.status == .standBy && !store.guideInformation.goRight{
                        TimerViewComponents.Guide.GoRight()
                    }
                }
            }
        }
        struct StandBy: ViewModifier{
            let store: StoreOf<MainFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment:.top) {
                    if store.timerProgressEntity.status == .standBy && !store.guideInformation.standByGuide{
                        TimerViewComponents.Guide.StandBy()
                            .padding(.top,125)
                    }
                }
            }
        }
        struct Focus: ViewModifier{
            let store: StoreOf<MainFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment:.top) {
                    ZStack {
                        if store.timerProgressEntity.status == .focus && !store.guideInformation.startGuide{
                            TimerViewComponents.Guide.Focus()
                                .padding(.top,25)
                                .opacity(!store.guideInformation.startGuide ? 1 : 0)
                        }else{
                            EmptyView()
                        }
                    }.transition(.opacity)
                }
            }
        }
    }
    struct Reset: ViewModifier{
        let store: StoreOf<MainFeature>
        func body(content: Content) -> some View {
            content.overlay(alignment: .top, content: {
                switch store.timerProgressEntity.status{
                case .pause,.breakTime:
                    TimerViewComponents.ResetButton(store: store).padding(.top,25)
                default: EmptyView()
                }
            })
        }
    }
    struct Session: ViewModifier{
        @Bindable var store: StoreOf<MainFeature>
        func body(content: Content) -> some View {
            content.overlay(alignment: .top, content: {
                    TimerViewComponents.FocusSessionButton(store: store).padding(.top,93)
                    .sheet(item: $store.scope(state: \.timerSession, action: \.timerSession)) { timerSessionStore in
                        TimerSessionView(store: timerSessionStore).presentationCornerRadius(24)
                    }
            })
        }
    }
    struct Init: ViewModifier{
        let store: StoreOf<MainFeature>
        func body(content: Content) -> some View {
            content.onAppear(){
                store.send(.initAction)
            }
        }
    }
    struct SkipBreakInfo: ViewModifier{
        let store: StoreOf<MainFeature>
        func body(content: Content) -> some View {
            content.overlay(alignment:.top) {
                ZStack {
                    if store.isSkipped{
                        TimerViewComponents.SkipInfo()
                            .padding(.top,25)
                            .opacity(store.isSkipped ? 1 : 0)
                    }else{
                        EmptyView()
                    }
                }.transition(.opacity)
            }
        }
    }
}
