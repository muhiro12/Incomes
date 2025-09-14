//
//  AppIntent.swift
//  Widgets
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import AppIntents
import WidgetKit

enum MonthSelection: String, AppEnum {
    case previousMonth
    case currentMonth
    case nextMonth

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Target Month")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .previousMonth: .init(title: "Previous Month"),
            .currentMonth: .init(title: "Current Month"),
            .nextMonth: .init(title: "Next Month")
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Incomes widgets configuration" }

    @Parameter(title: "Target Month", default: .currentMonth)
    var targetMonth: MonthSelection
}

// MARK: - Upcoming configuration (next or previous)

enum UpcomingDirection: String, AppEnum {
    case next
    case previous

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Direction")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .next: .init(title: "Next"),
            .previous: .init(title: "Previous")
        ]
    }
}

struct UpcomingConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Upcoming Configuration" }
    static var description: IntentDescription { "Configure upcoming widget direction" }

    @Parameter(title: "Direction", default: .next)
    var direction: UpcomingDirection
}
