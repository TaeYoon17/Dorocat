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
//    @State private var hour = ""
    @State private var minutes = ""
    @State private var isToggle = false
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
                        Toggle("하이", isOn: $store.isPomodoroMode.sending(\.setPomodoroMode))
                    })
                    if store.isPomodoroMode{
                        VStack(content: {
                            fiedls().frame(height:64)
                            Text("Short Break")
                            Text("Long Break")
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
extension TimerSettingView{
    @ViewBuilder func fiedls() -> some View{
        HStack(content: {
            Text("Cycle")
            Spacer()
            Picker("Cycle nums",selection: $selectedColor){
                ForEach(1...10,id:\.self){
                    Text("\($0)")
                }
            }.pickerStyle(.wheel).frame(width: 44)
        })
    }
}
struct CustomPicker:View{
    var body: some View{
        Text("Hello world")
    }
}
