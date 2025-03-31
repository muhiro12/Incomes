//
//  YearChartsView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/30/24.
//

import SwiftUI

struct YearChartsView: View {
    @Environment(ItemService.self)
    private var itemService

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let date: Date

    init(date: Date) {
        self.date = date
    }

    var body: some View {
        List {
            ChartSectionGroup(.items(.dateIsSameYearAs(date)))
        }
        .navigationTitle(date.stringValue(.yyyy))
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                if let count = try? itemService.itemsCount(.items(.dateIsSameYearAs(date))) {
                    Text("\(count) Items")
                        .font(.footnote)
                }
                Spacer()
                CreateItemButton()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            YearChartsView(date: .now)
        }
    }
}
