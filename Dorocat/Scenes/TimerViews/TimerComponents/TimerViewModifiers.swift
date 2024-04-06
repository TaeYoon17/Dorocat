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
                        Text("Left")
                    }
                }
            }
        }
        struct GoRight: ViewModifier{
            let store: StoreOf<TimerFeature>
            func body(content: Content) -> some View {
                content.overlay(alignment: .trailing) {
                    if store.timerStatus == .standBy && !store.guideInformation.goRight{
                        Text("Right")
                    }
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
    struct Init: ViewModifier{
        let store: StoreOf<TimerFeature>
        func body(content: Content) -> some View {
            content.onAppear(){
                store.send(.initAction)
            }
        }
    }
}
