//
//  TimerViewComponents.swift
//  Dorocat
//
//  Created by Developer on 4/6/24.
//

import SwiftUI
import ComposableArchitecture

enum TimerViewComponents{
    struct TriggerBtn: View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            WithPerceptionTracking {
                let text = switch store.timerStatus{
                case .breakTime: "Stop Break"
                case .completed: "Break"
                case .standBy: "Start"
                case .focus:"Pause"
                case .pause(.focusPause): "Start"
                default: ""
                }
                Button(text){
                    store.send(.triggerTapped)
                }.triggerStyle(scale: store.timerStatus == .breakTime ? .flexed : .fixed(110))
            }
        }
    }
    enum Timer{
        struct NumberField:View{
            let store: StoreOf<TimerFeature>
            var body: some View{
                HStack(content: {
                    Text(store.timer)
                        .font(.header01)
                        .foregroundStyle(.doroWhite)
                        .onTapGesture {
                            store.send(.timerFieldTapped)
                        }
                })
            }
        }
        struct CircleField: View{
            let store: StoreOf<TimerFeature>
            var body: some View{
                Circle().fill(Color.red)
                    .overlay(content: {
                        Text("원형 타이머")
                    })
                    .frame(width: 120,height: 120)
                    .onTapGesture {
                        store.send(.circleTimerTapped)
                    }
            }
        }
    }
    struct DoroCat:View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            Button(action: {
                store.send(.catTapped)
            }, label: {
                Text("고양이").font(.largeTitle)
                    .frame(width: 304,height: 304)
                    .background(.yellow)
            })
        }
    }
    struct ResetButton: View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            Button{
                store.send(.resetTapped)
            }label: {
                Text("Reset")
                    .font(.button)
                    .foregroundStyle(.doroWhite)
                    .padding(.horizontal,20)
                    .padding(.vertical,13.5)
                    .background(.grey03)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
extension TimerViewComponents{
    enum Guide{
        struct GoLeft:View{
            var body: some View{
                Image(.leftGuide).resizable()
                    .scaledToFit()
                    .frame(height:314)
                    .overlay(alignment: .leading) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16,height: 16)
                            .foregroundStyle(.grey01)
                            .padding(.leading,4)
                    }
            }
        }
        struct GoRight: View {
            var body: some View {
                Image(.rightGuide).resizable()
                    .scaledToFit()
                    .frame(height: 314)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16,height: 16)
                            .foregroundStyle(.grey01)
                            .padding(.trailing,4)
                    }
            }
        }
        struct Onboarding:View{
            var body: some View{
                Text("Let the cat snooze and get started!")
                    .font(.paragraph03())
                    .padding(.horizontal,20)
                    .padding(.vertical,14)
                    .background(.grey03)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}
