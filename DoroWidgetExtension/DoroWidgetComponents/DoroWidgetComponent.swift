//
//  DoroWidgetComponent.swift
//  Dorocat
//
//  Created by Developer on 5/19/24.
//

import SwiftUI
import ActivityKit
import WidgetKit
import AppIntents
extension DoroWidgetComponent{
    struct TriggerBtn:View {
        let context: ActivityViewContext<PomoAttributes>
        var body: some View {
            switch context.state.timerStatus{
            case .breakSleep: BtnView(info: info)
            case .focusSleep: IntentBtnView(info: info, intent: FocusSleepToPauseIntent())
            case .pause: IntentBtnView(info: info, intent: PauseToFocusSleepIntent())
            case .standBy: BtnView(info: info)
            }
        }
        var btnIntent: any LiveActivityIntent{
            switch context.state.timerStatus{
            case .breakSleep:
                BreakSleepToStandbyIntent()
            case .focusSleep:
                FocusSleepToPauseIntent()
            case .pause:
                PauseToFocusSleepIntent()
            case .standBy:
                FocusSleepToPauseIntent()
            }
        }
        var info:String{
            switch context.state.timerStatus{
            case .breakSleep: "Open"
            case .focusSleep: "Pause"
            case .pause: "Resume"
            case .standBy: "Start"
            }
        }
        struct IntentBtnView: View{
            let info:String
            let intent: any LiveActivityIntent
            var body: some View{
                Toggle(isOn: false, intent: self.intent) {
                    TriggerBtnView(info: info)
                }.buttonBorderShape(.capsule).buttonStyle(.plain)
            }
        }
        struct BtnView: View {
            let info:String
            var body: some View {
                Toggle(isOn: .constant(false)) {
                    TriggerBtnView(info: info)
                }.buttonBorderShape(.capsule).buttonStyle(.plain)
            }
        }
        struct TriggerBtnView: View{
            let info:String
            var body: some View{
                Text(info).font(.custom("DarumadropOne-Regular", size: 18)).minimumScaleFactor(0.5).fontCoordinator()
                    .lineLimit(1)
                    .foregroundStyle(.doroWhite)
                    .padding(.horizontal,20)
                    .padding(.vertical,9)
                    .background(.grey04)
                    .clipShape(Capsule())
            }
        }
    }
}
extension DoroWidgetComponent{
    struct TimerText:View {
        let context: ActivityViewContext<PomoAttributes>
        var body: some View {
            switch context.state.timerStatus {
            case .focusSleep,.breakSleep:
                Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),since: .now))
                    .font(.custom("DarumadropOne-Regular", size: 46)).foregroundStyle(.doroWhite)
                    .fontCoordinator()
            case .pause,.standBy:
                let hour = context.state.count / 60
                let min = context.state.count % 60
                Text("\(hour):\(min)")
                    .font(.custom("DarumadropOne-Regular", size: 46)).foregroundStyle(.doroWhite)
                    .fontCoordinator()
            }
            
        }
    }
}

