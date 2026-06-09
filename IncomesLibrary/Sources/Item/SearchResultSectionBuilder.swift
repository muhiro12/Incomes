//
//  SearchResultSectionBuilder.swift
//  IncomesLibrary
//
//  Builds month sections for item search results.
//

import Foundation

/// Builds month-based sections for item search results.
public enum SearchResultSectionBuilder {
    /// A month section containing matching items.
    public struct Section {
        /// First day of the represented local month.
        public let month: Date
        /// Display title for the represented month.
        public var title: String {
            month.formatted(.dateTime.year().month())
        }
        /// Items belonging to the represented month.
        public let items: [Item]
    }

    /// Groups items by local month and returns sections from newest to oldest.
    public static func sections(
        for items: [Item],
        calendar: Calendar = .current
    ) -> [Section] {
        let groupedItems = Dictionary(grouping: items) { item in
            calendar.startOfMonth(for: item.localDate)
        }
        return groupedItems.keys
            .sorted(by: >)
            .map { month in
                .init(
                    month: month,
                    items: groupedItems[month] ?? []
                )
            }
    }
}
