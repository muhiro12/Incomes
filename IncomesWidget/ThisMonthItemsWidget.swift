//
//  ThisMonthItemsWidget.swift
//  IncomesWidget
//
//  Created by Codex on 2025/06/10.
//

import SwiftUI
import WidgetKit
import SwiftData

struct ThisMonthItemsProvider: TimelineProvider {
    func placeholder(in context: Context) -> ThisMonthItemsEntry {
        .init(date: .now, items: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (ThisMonthItemsEntry) -> Void) {
        let items = fetchItems()
        completion(.init(date: .now, items: items))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThisMonthItemsEntry>) -> Void) {
        let items = fetchItems()
        let entry = ThisMonthItemsEntry(date: .now, items: items)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func fetchItems() -> [Item] {
        do {
            let container = try ModelContainer(
                for: Item.self,
                configurations: .init(
                    url: .applicationSupportDirectory.appendingPathComponent("Incomes.sqlite")
                )
            )
            let service = ItemService(context: container.mainContext)
            return try service.items(.items(.dateIsSameMonthAs(.now))).prefix(3).map { $0 }
        } catch {
            return []
        }
    }
}

struct ThisMonthItemsEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}

struct ThisMonthItemsWidgetEntryView: View {
    var entry: ThisMonthItemsProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(entry.items) { item in
                NarrowListItem()
                    .environment(item)
            }
        }
        .padding()
    }
}

struct ThisMonthItemsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: ThisMonthItemsProvider()) { entry in
            ThisMonthItemsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }

    static let kind = "ThisMonthItemsWidget"
}

#Preview(as: .systemMedium) {
    ThisMonthItemsWidget()
} timeline: {
    ThisMonthItemsEntry(date: .now, items: [])
}
