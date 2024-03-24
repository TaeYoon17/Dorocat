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
    @State private var minutes = ""
    @State private var selectedColor = ""
    var body: some View {
        WithPerceptionTracking{
            ScrollView {
                VStack(alignment:.center,content: {
                    HStack(content: {
                        TextField("00", text: $store.time.sending(\.setTime))
                            .keyboardType(.numberPad)
                        Text("min")
                    })
                    HStack(content: {
                        Text("Pomodoro Mode")
                        // Custom Toggler 만들기
                        Toggle("하이", isOn: $store.isPomodoroMode.sending(\.setPomodoroMode)).backgroundStyle(.blue)
                    })
                    if store.isPomodoroMode{
                        VStack(content: {
                            fiedls(type:.cycle)
                            fiedls(type:.shortBreak)
                            fiedls(type: .longBreak)
                        })
                    }
                    Button(action: {
                        store.send(.doneTapped)
                    }, label: {
                        Text("Done")
                    })
                })
            }
            .padding(.horizontal)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        store.send(.cancelTapped)
                    }, label: {
                        Text("Cancel")
                    })
                }
            })
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
        })
    }
}
struct CustomPicker:View{
    var body: some View{
        Text("Hello world")
    }
}
