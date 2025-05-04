//
//  TimerSettingFieldView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

enum TimerSettingViewComponent {
    struct Field: View {
        var text: String
        @Binding var isOn: Bool
        var body: some View {
            VStack(spacing: 21) {
                HStack {
                    if text.isEmpty {
                        Text("00").foregroundStyle(Color.grey03)
                    } else {
                        if text.count == 2 {
                            Text(text).foregroundStyle(Color.doroWhite)
                        } else if text.count == 1 {
                            (Text("0").foregroundColor(Color.grey03) + Text(text).foregroundColor(Color.doroWhite))
                        }
                    }
                    Text("min")
                }
                .font(.header02)
                .foregroundStyle(Color.doroWhite)
                HStack(content: {
                    Text("Pomodoro mode")
                        .foregroundStyle(Color.grey01)
                        .font(.paragraph03(.bold))
                    DoroTogglerView(isOn: $isOn,toggleSize: .small)
                        .frame(width: 40,height:22)
                })
            }
        }
    }
    struct ListItem: View {
        let title:String
        let type: TimerSettingFeature.SettingType
        @Binding var selectedIdx:Int
        var body: some View {
            HStack {
                Text(title).font(.paragraph02()).foregroundStyle(Color.doroWhite).fontCoordinator()
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
                }).font(.paragraph02(.bold)).foregroundStyle(Color.doroWhite).fontCoordinator()
            }.modifier(ListItemBgModifier())
        }
    }
}

struct ListItemBgModifier:ViewModifier{
    func body(content: Content) -> some View {
        content
            .frame(height: 60)
            .padding(.horizontal,16)
            .background(Color.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview(body: {
    TimerSettingView(store: Store(initialState: TimerSettingFeature.State(), reducer: {
        TimerSettingFeature()
    }))
})

