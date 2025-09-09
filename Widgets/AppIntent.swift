//
//  AppIntent.swift
//  Widgets
//
//  Created by Hiromu Nakano on 2025/09/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
