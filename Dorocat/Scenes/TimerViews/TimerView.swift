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
                switch store.timerStatus{
                case .pause,.shortBreak,.longBreak: resetBtn
                default: EmptyView()
                }
                if store.timerStatus == .completed{
                    VStack {
                        Text("Well done!").font(.title2).bold()
                        Text("You've completed successfully")
                        Text("2h 30m")
                    }
                }
                doroCat
                if store.timerStatus == .running{
                    circleTimer
                }
                switch store.timerStatus{
                case .standBy,.running,.pause: numberFieldTimer
                case .completed: completeBtn
                case .shortBreak:
                    VStack {
                        Text("Short Break")
                        numberFieldTimer
                    }
                case .longBreak:
                    VStack {
                        Text("Long Break")
                        numberFieldTimer
                    }
                }
            })
            .sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                TimerSettingView(store: timerSettingStore)
                    .presentationDetents([.medium,.large])
            }
        }
    }
}

#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}
extension TimerView{
    var numberFieldTimer: some View{
        HStack(content: {
            Text(store.timer)
                .font(.header01)
                .foregroundStyle(.grey02)
                .onTapGesture {
                    store.send(.timerFieldTapped)
                }
        })
    }
    
    var circleTimer: some View{
        Circle().fill(Color.red)
            .overlay(content: {
                Text("원형 타이머")
            })
            .frame(width: 120,height: 120)
            .onTapGesture {
                store.send(.circleTimerTapped)
            }
    }
    var doroCat: some View{
        Button(action: {
            store.send(.catTapped)
        }, label: {
            Text("고양이").font(.title)
        })
    }
    var resetBtn: some View{
        Button{
            store.send(.resetTapped)
        }label: {
            Text("Reset")
                .padding().background(.white)
        }
    }
    var completeBtn: some View{
        Button{
            store.send(.completeTapped)
        }label:{
            Text("Complete")
        }
    }
}
// 기존 타이머 앱에서 타이머를 구현하는 방법...
//.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
//    if pomodoroModel.isStarted{
//        pomodoroModel.updateTimer()
//    }
//})
