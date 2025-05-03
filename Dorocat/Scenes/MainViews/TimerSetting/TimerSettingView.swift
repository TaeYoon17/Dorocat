//
//  TimerSettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

struct TimerSettingView:View {
    @Bindable var store: StoreOf<TimerSettingFeature>
    var body: some View {
            VStack {
                if store.isPomodoroMode{
                    Rectangle().fill(.clear).frame(height:56)
                }else{
                    Spacer()
                    Spacer()
                }
                VStack(alignment: .center,spacing:0, content: {
                    TimerSettingViewComponent.Field(text: store.time,isOn: $store.isPomodoroMode.sending(\.setPomodoroMode))
                        .padding(.bottom,41)
                    if store.isPomodoroMode{
                        VStack(spacing:8,content: {
                            TimerSettingViewComponent.ListItem(title: "Cycles Amount",
                                                               type: .cycle,
                                                               selectedIdx: $store.cycleTime.sending(\.setCycleTime))
                            TimerSettingViewComponent.ListItem(title: "Break Duration",
                                                               type: .breakDuration,
                                                               selectedIdx: $store.breakTime.sending(\.setBreakTime))
                        })
                    }
                })
                .padding()
                Spacer()
                VStack (spacing:24){
                    Button("Done"){ store.send(.doneTapped) }.doneStyle()
                    DoroNumberPad(text: $store.time.sending(\.setTime)).frame(maxWidth: .infinity)
                }
            }.frame(maxWidth: .infinity)
            .background(Color.grey04)
    }
}
extension TimerSettingView{
    @ViewBuilder func fiedls(type:TimerSettingFeature.SettingType) -> some View{
        let wow:Binding<Int> = switch type{
        case .cycle:
            $store.cycleTime.sending(\.setCycleTime)
        case .breakDuration:
            $store.breakTime.sending(\.setBreakTime)
        }
        HStack(content: {
            Text(type.title)
            Spacer()
            HStack {
                NumberPickerView(number: wow, range: type.range)
                    .frame(width: 44,height:80)
                    .clipped()
                    
                if type != .cycle{
                    Text("min")
                }
            }.font(.paragraph02(.bold))
        }).frame(height:66)
    }
}

#Preview(body: {
    TimerSettingView(store: Store(initialState: TimerSettingFeature.State(), reducer: {
        TimerSettingFeature()
    }))
})
