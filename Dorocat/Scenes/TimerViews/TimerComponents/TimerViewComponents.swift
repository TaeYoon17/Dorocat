//
//  TimerViewComponents.swift
//  Dorocat
//
//  Created by Developer on 4/6/24.
//

import SwiftUI
import ComposableArchitecture
fileprivate extension TimerFeatureStatus{
    var text:String{
        switch self{
        case .breakTime: "Stop Break"
        case .completed: "Complete"
        case .standBy: "Start"
        case .focus:"Pause"
        case .pause: "Resume"
        case .breakStandBy: "Break"
        default: ""
        }
    }
}
enum TimerViewComponents{
    struct TriggerBtn: View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            Group{
                switch store.timerStatus{
                case .pause:
                    HStack(spacing: 12) {
                        Button("Reset"){
                            store.send(.viewAction(.resetTapped))
                        }.resetStyle {
                            store.send(.viewAction(.triggerWillTap(.soft)))
                        }
                        Button(store.timerStatus.text){
                            store.send(.viewAction(.triggerTapped))
                        }.triggerStyle(status: btnType, willTap: {
                            store.send(.viewAction(.triggerWillTap()))
                        })
                    }
                default:
                    Button(store.timerStatus.text){
                        store.send(.viewAction(.triggerTapped))
                    }.triggerStyle(status: btnType, willTap: {
                        store.send(.viewAction(.triggerWillTap()))
                    })
                    .animation(nil, value: store.timerStatus)
                }
            }
        }
        var text:String{
            switch store.timerStatus{
            case .breakTime: "Stop Break"
            case .completed: "Complete"
            case .standBy: "Start"
            case .focus:"Pause"
            case .pause: "Start"
            case .breakStandBy: "Break"
            default: ""
            }
        }
        var btnType:TriggerBtnStyle.TriggerType{
            switch store.timerStatus{
            case .breakStandBy: return .goBreak
            case .breakTime: return .stopBreak
            case .focus: return .pause
            case .standBy: return .start
            case .completed: return .complete
            case .pause: return .resume
            case .sleep(.focusSleep): return .pause
            case .sleep(.breakSleep): return .stopBreak
            }
        }
    }
    enum Timer{
        struct NumberField:View{
            let store: StoreOf<TimerFeature>
            var body: some View{
                HStack(content: {
                    Spacer()
                    HStack (alignment: .center,spacing:1){
                        HStack{
                            Spacer()
                            Text(store.timer.prefix(2))
                        }
                        Text(":")
                        HStack {
                            Text(store.timer.suffix(2))
                            Spacer()
                        }
                    }
                    .font(.header01).foregroundStyle(.doroWhite)
                    .onTapGesture {
                        store.send(.viewAction(.timerFieldTapped))
                    }
                    Spacer()
                })
            }
        }
    }
    struct TotalFocusTimeView: View {
        let store: StoreOf<TimerFeature>
        var body: some View {
            HStack{
                Image(.completeIcon)
                Text(store.totalTime)
            }.font(.paragraph03())
                .foregroundStyle(.grey00)
                .padding(.horizontal,20)
                .padding(.vertical,10)
                .background(.grey03)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(height: 40)
                .padding(.bottom,22)
        }
    }
    struct ResetButton: View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            Button("Reset"){
                store.send(.viewAction(.resetTapped))
            }.resetStyle()
        }
    }
}


#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}
