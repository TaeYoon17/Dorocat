//
//  DoroWidgetExtensionLiveActivity.swift
//  DoroWidgetExtension
//
//  Created by Developer on 4/23/24.
//

import ActivityKit
import WidgetKit
import SwiftUI
enum DoroWidgetComponent{}

struct DoroWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack(content: {
                Image(context.state.catType.lockImageLabel).resizable().scaledToFill().frame(width: 60,height:60)
                    .padding(.trailing,16)
                VStack(alignment:.leading,spacing: 0,content: {
                    Text(context.state.timerSession.name).font(.button).foregroundStyle(.grey01)
                    HStack(content: {
                        DoroWidgetComponent.TimerText(context: context)
                        Spacer()
                        DoroWidgetComponent.TriggerBtn(context: context)
                    })
                })
            })
            .activityBackgroundTint(.grey04.opacity(0.85))
            .activitySystemActionForegroundColor(Color.black)
            .padding(.bottom,24).padding([.top,.leading],20).padding(.trailing,18.5)
        } dynamicIsland: { context in
            return DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
//                    Image(.cat).resizable().scaledToFit()
                    Text("Dorodoro")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("DoroCat")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    
                    Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),since: .now))
                    // more content
                }
            } compactLeading: {
                Image(context.state.catType.compactLabel).resizable().scaledToFit()
                    .frame(width: 38)
            } compactTrailing: {
                Group{
                    switch context.state.timerStatus {
                    case .focusSleep,.breakSleep:
                        Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),since: .now)).foregroundStyle(.doroWhite)
                    case .pause,.standBy:
                        let hour = context.state.count / 60
                        let min = context.state.count % 60
                        Text("\(hour):\(min)").foregroundStyle(.doroWhite)
                    }
                }.frame(width:48)
            } minimal: {
                let start = Date.now.addingTimeInterval(TimeInterval(-context.state.endTime+context.state.count))
                let end = Date.now.addingTimeInterval(TimeInterval(context.state.endTime))
                ProgressView(timerInterval: start...end,countsDown: false
                ) {
                    EmptyView()
                }currentValueLabel: {
                    
                    EmptyView()
                }.progressViewStyle(.circular)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
