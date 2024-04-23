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
    @State private var count = 0
    @State private var limit = 0
    @State private var timer:Timer?
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.count)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            limit = context.state.count
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
                    Text("Bottom \(context.state.count)")
                    // more content
                }
            } compactLeading: {
//                Image(.cat).resizable().scaledToFit()
                Text("D")
            } compactTrailing: {
                Text(timerInterval: Date.now...Date(timeInterval: TimeInterval(context.state.count),since: .now))
            } minimal: {
                Text("\(context.state.count)")
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
