//
//  TimerSettingFieldView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import ComposableArchitecture
enum TimerSettingViewComponent{
    struct Field:View{
        @State var text = ""
        @State var isOn = false
        @FocusState private var keyboardFocused: Bool
        var body: some View{
            VStack(spacing: 21) {
                HStack{
                    TextField("", text: $text)
                        .keyboardType(.numberPad)
                        .focused($keyboardFocused)
                        .frame(minWidth: 43,maxWidth: 62)
                        .onAppear(){
                            
                        }
                    Text("min")
                }
                .font(.header02)
                .foregroundStyle(.white)
                HStack(content: {
                    Text("Pomodoro mode")
                        .foregroundStyle(.grey01)
                        .font(.paragraph03(.bold))
                    Toggle("", isOn: $isOn).frame(width: 37)
                })
            }.onAppear(){
                Task{@MainActor in
                    try await Task.sleep(for: .seconds(0.1))
                    keyboardFocused = true
                }
            }
        }
    }
    struct ListItem:View{
        enum SettingType{
            case cycle
            case breakDuration
        }
        let title:String
        let type: SettingType
        @State private var selectedIdx = 1
        var body: some View{
            HStack {
                Text(title).font(.paragraph02()).foregroundStyle(.white)
                Spacer()
                HStack(spacing:0,content: {
                    Picker("Cycle nums",selection: $selectedIdx){
                        ForEach(1...10,id:\.self){
                            Text("\($0)")
                                .font(.paragraph02(.bold)).foregroundStyle(.white)
                                .tag($0)
                        }
                    }.pickerStyle(.wheel).frame(width: 44)
                    switch type{
                    case .breakDuration: Text("min")
                    case .cycle: EmptyView()
                    }
                }).font(.paragraph02(.bold)).foregroundStyle(.white)
            }.modifier(ListItemBgModifier())
        }
    }
}
struct ListItemBgModifier:ViewModifier{
    func body(content: Content) -> some View {
        content
            .frame(height: 60)
            .padding(.horizontal,16)
            .background(.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
    }
}

#Preview(body: {
    TimerSettingView(store: Store(initialState: TimerSettingFeature.State(), reducer: {
        TimerSettingFeature()
    }))
})
 
