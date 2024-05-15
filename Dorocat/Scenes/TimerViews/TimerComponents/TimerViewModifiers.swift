//
//  TimerViewModifiers.swift
//  Dorocat
//
//  Created by Developer on 4/6/24.
//

import SwiftUI
import ComposableArchitecture
enum TimerViewModifiers{
    enum Guide{
        struct GoLeft:ViewModifier{
            let store: StoreOf<TimerFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment: .leading) {
                    if store.timerStatus == .standBy && !store.guideInformation.goLeft{
                        TimerViewComponents.Guide.GoLeft()
                    }
                }
            }
        }
        struct GoRight: ViewModifier{
            let store: StoreOf<TimerFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment: .trailing) {
                    if store.timerStatus == .standBy && !store.guideInformation.goRight{
                        TimerViewComponents.Guide.GoRight()
                    }
                }
            }
        }
        struct StandBy: ViewModifier{
            let store: StoreOf<TimerFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment:.top) {
                    if store.timerStatus == .standBy && !store.guideInformation.standByGuide{
                        TimerViewComponents.Guide.StandBy()
                            .padding(.top,125)
                    }
                }
            }
        }
        struct Focus: ViewModifier{
            let store: StoreOf<TimerFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment:.top) {
                    ZStack {
                        if store.timerStatus == .focus && !store.guideInformation.startGuide{
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
        let store: StoreOf<TimerFeature>
        func body(content: Content) -> some View {
            content.overlay(alignment: .top, content: {
                switch store.timerStatus{
                case .pause,.breakTime:
                    TimerViewComponents.ResetButton(store: store).padding(.top,25)
                default: EmptyView()
                }
            })
        }
    }
    struct Session: ViewModifier{
        let store: StoreOf<TimerFeature>
        func body(content: Content) -> some View {
            content.overlay(alignment: .top, content: {
                TimerViewComponents.FocusSessionButton(store: store).padding(.top,93)
            })
        }
    }
    struct Init: ViewModifier{
        let store: StoreOf<TimerFeature>
        func body(content: Content) -> some View {
            content.onAppear(){
                store.send(.initAction)
            }
        }
    }
}
