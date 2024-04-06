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
                Spacer()
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
                Spacer()
                switch store.timerStatus{
                case .standBy,.focus,.pause: 
                    numberFieldTimer
                    triggerBtn
                case .completed:
                    triggerBtn
                case .breakTime:
                    triggerBtn
                }
                
            }).frame(maxWidth: .infinity)
            .overlay(alignment: .top, content: {
                    switch store.timerStatus{
                    case .pause,.breakTime: resetBtn.padding(.top,25)
                    default: EmptyView()
                    }
            })
            .overlay(content: {
//                if store.timerStatus == .standBy{
//                    HStack {
//                        if !store.guideInformation.goLeft{
//                            Text("Left")
//                        }
//                        Spacer()
//                        if !store.guideInformation.goRight{
//                            Text("Right")
//                        }
//                    }.frame(maxWidth: .infinity).background(.yellow)
//                }
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
                .padding(.horizontal,20)
                .padding(.vertical,13.5)
                .background(.grey03)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    var triggerBtn: some View{
        let text = switch store.timerStatus{
        case .breakTime: "Stop Break"
        case .completed: "Break"
        case .standBy: "Start"
        case .focus:"Pause"
        case .pause(.focusPause): "Start"
        default: ""
        }
        return Button(text){
            store.send(.triggerTapped)
        }.triggerStyle(scale: store.timerStatus == .breakTime ? .flexed : .fixed(110))
    }
}
