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
                case .completed:
                    Button("Break"){
                        print("Button is pressed!!")
                    }.triggerStyle
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
            }).frame(maxWidth: .infinity)
            .overlay(content: {
                if store.timerStatus == .standBy{
                    HStack {
                        if !store.guideInformation.goLeft{
                            Text("Left")
                        }
                        Spacer()
                        if !store.guideInformation.goRight{
                            Text("Right")
                        }
                    }.frame(maxWidth: .infinity).background(.yellow)
                }
            })
            .sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                TimerSettingView(store: timerSettingStore).presentationDetents([.large])
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
                .foregroundStyle(.doroWhite)
                .onTapGesture {
                    store.send(.timerFieldTapped)
                }
            
        })
        .overlay(alignment: .bottom) {
            if store.timerStatus == .standBy{
                Text("Tap to change timer")
                    .font(.title2)
                    .background(.thinMaterial)
                    .offset(y:44)
            }
        }
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
                .frame(width: 304,height: 304)
                .background(.yellow)
        })
    }
    var timerBtn: some View{
        Button("Start"){
            print("스타트!!")
        }
    }
    var resetBtn: some View{
        Button{
            store.send(.resetTapped)
        }label: {
            Text("Reset")
                .font(.button)
                .foregroundStyle(.doroWhite)
                .padding()
                .background(.grey03)
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
        Button("Start"){
            print("Button is pressed!!")
        }.triggerStyle
    }
}
// 기존 타이머 앱에서 타이머를 구현하는 방법...
//.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
//    if pomodoroModel.isStarted{
//        pomodoroModel.updateTimer()
//    }
//})

