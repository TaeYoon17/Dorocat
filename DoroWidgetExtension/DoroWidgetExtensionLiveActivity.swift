//
//  DoroWidgetExtensionLiveActivity.swift
//  DoroWidgetExtension
//
//  Created by Developer on 4/23/24.
//

import ActivityKit
import WidgetKit
import SwiftUI
import DoroDesignSystem
enum DoroWidgetComponent{}

struct DoroWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack(content: {
                Image(context.state.catType.lockImageLabel).resizable().scaledToFill().frame(width: 60,height:60)
                    .padding(.trailing,16 * 0.5)
                VStack(alignment:.leading,spacing:0,content: {
                    let topInfo:String = if context.state.timerStatus == .breakSleep{
                        "Break"
                    }else{
                        context.state.timerSession.name
                    }
                    Text(topInfo).font(.button).foregroundStyle(.grey01).offset(x:2,y:8)
                    HStack(content: {
                        DoroWidgetComponent.TimerText(context: context).fontCoordinator()
                        Spacer()
                        DoroWidgetComponent.TriggerBtn(context: context)
                    })
                })
            })
            .activityBackgroundTint(.grey04.opacity(0.85))
            .activitySystemActionForegroundColor(.doroBlack)
            .padding(.bottom,16).padding([.top,.leading],20).padding(.trailing,18.5)
        } dynamicIsland: { context in
            return DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.center) {
                    HStack(content: {
                        Image(context.state.catType.lockImageLabel).resizable().scaledToFill().frame(width: 60,height:60)
                            .padding(.trailing,16 * 0.5)
                        VStack(alignment:.leading,spacing:0,content: {
                            Text(context.state.timerSession.name).font(.button).foregroundStyle(.grey01).offset(x:2,y:8)
                            HStack(content: {
                                DoroWidgetComponent.TimerText(context: context).fontCoordinator()
                                Spacer()
                                DoroWidgetComponent.TriggerBtn(context: context)
                            })
                        })
                    })
                }
            } compactLeading: {
                Image(context.state.catType.compactLabel).resizable().scaledToFit()
                    .frame(width:24)
            } compactTrailing: {
                HStack{
                    Spacer()
                    switch context.state.timerStatus {
                    case .focusSleep,.breakSleep:
                        Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),since: .now)).foregroundStyle(.doroWhite).font(.custom("DarumadropOne-Regular", size: 16)).fontCoordinator()
                    case .pause,.standBy:
                        let hour = context.state.count / 60
                        let min = context.state.count % 60
                        Text("\(hour):\(min)").foregroundStyle(.doroWhite).font(.custom("DarumadropOne-Regular", size: 16)).fontCoordinator()
                    }
                }.frame(width:50)
            } minimal: {
                Image(context.state.catType.compactLabel).resizable().scaledToFit()
                    .frame(width:24)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(.clear)
        }
    }
}
