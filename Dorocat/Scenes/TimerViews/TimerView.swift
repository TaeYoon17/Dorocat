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
                HStack(content: {
                    Text(store.timer).font(.largeTitle)
                })
                Button{
                    print("timersetting이 눌림!!")
                    store.send(.goTimerSetting)
                }label: {
                    Text("Go to timer setting")
                }
                Button(action: {
                    store.send(.stopTapped)
                }, label: {
                    Text("Stop")
                })
            }).sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                NavigationStack {
                    TimerSettingView(store: timerSettingStore)
                }
            }
//            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
//                print("타이머가 돌아간다...")
//            })
            
        }
    }
}

#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}

// 기존 타이머 앱에서 타이머를 구현하는 방법...
//.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
//    if pomodoroModel.isStarted{
//        pomodoroModel.updateTimer()
//    }
//})
