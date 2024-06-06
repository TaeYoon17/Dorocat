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
        var text:String
        @Binding var isOn:Bool
        var body: some View{
            VStack(spacing: 21) {
                HStack{
                    
                    if text.isEmpty{
                        Text("00").foregroundStyle(.grey03)
                    }else{
                        if text.count == 2{
                            Text(text).foregroundStyle(.doroWhite)
                        }else if text.count == 1{
                            (Text("0").foregroundColor(.grey03) + Text(text).foregroundColor(.doroWhite))
                        }
                    }
                    Text("min")
                }
//                .frame(width:173)
                .font(.header02)
                .foregroundStyle(.doroWhite)
                HStack(content: {
                    Text("Pomodoro mode")
                        .foregroundStyle(.grey01)
                        .font(.paragraph03(.bold))
                    DoroTogglerView(isOn: $isOn,toggleSize: .small)
                        .frame(width: 40,height:22)
                })
            }
        }
    }
    struct ListItem:View{
        let title:String
        let type: TimerSettingFeature.SettingType
        @Binding var selectedIdx:Int
        var body: some View{
            HStack {
                Text(title).font(.paragraph02()).foregroundStyle(.doroWhite)
                Spacer()
                HStack(spacing:0,content: {
                    NumberPickerView(number: $selectedIdx, range: type.range)
                        .frame(width: 44)
                        .clipped()
                        .contentShape(Rectangle())
                    switch type{
                    case .breakDuration: Text("min")
                    case .cycle: EmptyView()
                    }
                }).font(.paragraph02(.bold)).foregroundStyle(.doroWhite)
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

