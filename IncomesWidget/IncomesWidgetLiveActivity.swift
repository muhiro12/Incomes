//
//  IncomesWidgetLiveActivity.swift
//  IncomesWidget
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct IncomesWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct IncomesWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IncomesWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through
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

extension IncomesWidgetAttributes {
    fileprivate static var preview: IncomesWidgetAttributes {
        IncomesWidgetAttributes(name: "World")
    }
}

extension IncomesWidgetAttributes.ContentState {
    fileprivate static var smiley: IncomesWidgetAttributes.ContentState {
        IncomesWidgetAttributes.ContentState(emoji: "😀")
    }

    fileprivate static var starEyes: IncomesWidgetAttributes.ContentState {
        IncomesWidgetAttributes.ContentState(emoji: "🤩")
    }
}

#Preview("Notification", as: .content, using: IncomesWidgetAttributes.preview) {
    IncomesWidgetLiveActivity()
} contentStates: {
    IncomesWidgetAttributes.ContentState.smiley
    IncomesWidgetAttributes.ContentState.starEyes
}
