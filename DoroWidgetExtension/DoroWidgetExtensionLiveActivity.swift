//
//  DoroWidgetExtensionLiveActivity.swift
//  DoroWidgetExtension
//
//  Created by Developer on 4/23/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DoroWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DoroWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DoroWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DoroWidgetExtensionAttributes {
    fileprivate static var preview: DoroWidgetExtensionAttributes {
        DoroWidgetExtensionAttributes(name: "World")
    }
}

extension DoroWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: DoroWidgetExtensionAttributes.ContentState {
        DoroWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DoroWidgetExtensionAttributes.ContentState {
         DoroWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DoroWidgetExtensionAttributes.preview) {
   DoroWidgetExtensionLiveActivity()
} contentStates: {
    DoroWidgetExtensionAttributes.ContentState.smiley
    DoroWidgetExtensionAttributes.ContentState.starEyes
}
