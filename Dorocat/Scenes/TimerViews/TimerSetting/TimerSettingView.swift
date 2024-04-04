//
//  TimerSettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture

struct TimerSettingView:View {
    @Perception.Bindable var store: StoreOf<TimerSettingFeature>
    var body: some View {
        WithPerceptionTracking{
            ScrollView {
                VStack(alignment: .center, content: {
                    Rectangle().fill(.clear).frame(height:56)
                    TimerSettingViewComponent.Field()
//                    HStack(content: {
//                        Spacer()
//                        TextField("00", text: $store.time.sending(\.setTime))
//                            .font(.title)
//                            .keyboardType(.numberPad)
//                            .frame(width: 120).background(.red)
//                            .font(.title)
//                        Text("min")
//                        Spacer()
//                    }).padding()
//                    HStack(content: {
//                        Spacer()
//                        Text("Pomodoro Mode")
//
//                        // Custom Toggler 만들기
//                        Toggle("하이", isOn: $store.isPomodoroMode.sending(\.setPomodoroMode))
//                            .backgroundStyle(.blue)
//                        Spacer()
//                    })
//                    .font(.title3)
//                    .padding()
                    if !store.isPomodoroMode{
                        VStack(spacing:8,content: {
                            TimerSettingViewComponent.ListItem(title: "Cycles Amount", type: .cycle)
                            TimerSettingViewComponent.ListItem(title: "Break Duration", type: .breakDuration)
                        })
                    }else{
                        Rectangle().fill(.clear).frame(height:53)
                    }
                    Spacer()
                    Button(action: {
                        store.send(.doneTapped)
                    }, label: {
                        Text("Done").font(.paragraph02(.bold))
                            .padding()
                            .background(.white)
                            .clipShape(Capsule())
                            .foregroundStyle(.black)
                    })
                })
                .padding()
            }.frame(maxWidth: .infinity)
            .background(.grey04)
        }
    }
}
enum FieldType{
    case cycle
    case shortBreak
    case longBreak
    var title:String{
        switch self{
        case .cycle: "Cycle"
        case .longBreak: "Long Break"
        case .shortBreak: "Short Break"
        }
    }
    
}
extension TimerSettingView{
    @ViewBuilder func fiedls(type:FieldType) -> some View{
        let wow:Binding<Int> = switch type{
        case .cycle:
            $store.cycleTime.sending(\.setCycleTime)
        case .longBreak:
            $store.longBreak.sending(\.setLongBreak)
        case .shortBreak:
            $store.shortBreak.sending(\.setShortBreak)
        }
        HStack(content: {
            Text(type.title)
            Spacer()
            HStack {
                Picker("Cycle nums",selection: wow ){
                    ForEach(1...10,id:\.self){
                        Text("\($0)").tag($0)
                    }
                }.pickerStyle(.wheel).frame(width: 44)
                if type != .cycle{
                    Text("min")
                }
            }.font(.paragraph02(.bold))
        }).frame(height:66).background(.yellow)
    }
}
struct CustomPicker:View{
    var body: some View{
        Text("Hello world")
    }
}

#Preview(body: {
    TimerSettingView(store: Store(initialState: TimerSettingFeature.State(), reducer: {
        TimerSettingFeature()
    }))
})
