//
//  SearchResultView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct SearchResultView: View {
    @BridgeQuery private var items: [ItemEntity]

    init(predicate: ItemPredicate) {
        _items = .init(Query(.items(predicate)))
    }

    private var groupedItems: [Date: [ItemEntity]] {
        Dictionary(grouping: items) { item in
            Calendar.current.startOfMonth(for: item.date)
        }
    }

    private var sortedMonths: [Date] {
        groupedItems.keys.sorted(by: >)
    }

    var body: some View {
        Group {
            if items.isNotEmpty {
                List {
                    ForEach(sortedMonths, id: \.self) { month in
                        Section(month.formatted(.dateTime.year().month())) {
                            ForEach(groupedItems[month] ?? []) { item in
                                ListItem()
                                    .environment(item)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                }
            }
        }
        .navigationTitle("Results")
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            SearchResultView(predicate: .all)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            SearchResultView(predicate: .none)
        }
    }
}
