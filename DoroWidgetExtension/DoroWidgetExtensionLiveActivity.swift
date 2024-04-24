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
            VStack {
                Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),since: .now))
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

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
                Image(.cat).resizable().scaledToFit()
                    .frame(width: 38)
            } compactTrailing: {
                Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count / 60),
                                                    since: .now),showsHours: false)
                .monospacedDigit()
                .frame(width:48)
            } minimal: {
                let start = Date.now.addingTimeInterval(TimeInterval(-context.state.endTime+context.state.count))
                let end = Date.now.addingTimeInterval(TimeInterval(context.state.endTime))
                ProgressView(timerInterval: start...end,countsDown: false
                ) {
//                    Label("s", systemImage: "plus")
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
//
//extension DoroWidgetExtensionAttributes {
//    fileprivate static var preview: DoroWidgetExtensionAttributes {
//        DoroWidgetExtensionAttributes(name: "World")
//    }
//}
//
//extension DoroWidgetExtensionAttributes.ContentState {
//    fileprivate static var smiley: DoroWidgetExtensionAttributes.ContentState {
//        DoroWidgetExtensionAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: DoroWidgetExtensionAttributes.ContentState {
//         DoroWidgetExtensionAttributes.ContentState(emoji: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: DoroWidgetExtensionAttributes.preview) {
//   DoroWidgetExtensionLiveActivity()
//} contentStates: {
//    DoroWidgetExtensionAttributes.ContentState.smiley
//    DoroWidgetExtensionAttributes.ContentState.starEyes
//}
