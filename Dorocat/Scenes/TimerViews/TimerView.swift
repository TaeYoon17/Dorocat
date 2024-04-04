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
    @Environment(\.scenePhase) var phase
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
                    }.background(.yellow)
                }
                if store.timerInformation.isPomoMode{
                    Text(store.cycleNote).font(.title2).bold().background(.blue)
                }
                doroCat
                if store.timerStatus == .focus{
                    circleTimer
                }
                switch store.timerStatus{
                case .standBy,.focus,.pause: numberFieldTimer
                case .completed: completeBtn
                case .shortBreak:
                    VStack {
                        Text("Short Break")
                            .font(.title2)
                            .padding()
                            .background(.white)
                        numberFieldTimer
                    }
                case .longBreak:
                    VStack {
                        Text("Long Break")
                            .font(.title2)
                            .padding()
                            .background(.white)
                        numberFieldTimer
                    }
                }
                triggerBtn
            })
            .sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                TimerSettingView(store: timerSettingStore)
                    .presentationDetents([.fraction(0.8)])
                    
            }
            .onAppear(){
                store.send(.initAction)
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
                .foregroundStyle(.white)
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
            Text("고양이").font(.largeTitle)
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
    var triggerBtn: some View{
        Button {
            print("Hello world")
        } label: {
            Text("Start")
                .padding(.vertical,19.5)
                .padding(.horizontal,28)
                .background(.grey04)
                .overlay(content: {
                    Capsule().stroke(lineWidth: 1).fill(.grey02)
                }).shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 6)
                
        }
    }
}
// 기존 타이머 앱에서 타이머를 구현하는 방법...
//.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
//    if pomodoroModel.isStarted{
//        pomodoroModel.updateTimer()
//    }
//})
