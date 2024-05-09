//
//  DoroWidgetExtensionLiveActivity.swift
//  DoroWidgetExtension
//
//  Created by Developer on 4/23/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DoroWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack(content: {
                Image(.catLock).resizable().scaledToFill().frame(width: 60,height:60)
                    .padding(.trailing,16)
                VStack(alignment:.leading,spacing: 0,content: {
                    Text("Read").font(.button).foregroundStyle(.grey01)
                    HStack(content: {
                        Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),since: .now))
                            .font(.header03).foregroundStyle(.doroWhite)
                        Spacer()
                        Button(action: {
                            print("안녕하세요")
                        }, label: {
                            Text("Start").font(.header04)
                                .foregroundStyle(.doroWhite)
                                .padding(.horizontal,20)
                                .padding(.vertical,9)
                                .background(.grey04)
                                .clipShape(Capsule())
                        }).buttonBorderShape(.capsule).buttonStyle(.plain)
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
                Image(.compactCat).resizable().scaledToFit()
                    .frame(width: 38)
            } compactTrailing: {
                Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),
                                                    since: .now),showsHours: false).monospacedDigit()
                .frame(width:48)
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
