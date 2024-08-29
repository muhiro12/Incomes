//
//  MainNavigationDetailView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/29/24.
//

import SwiftUI

struct MainNavigationDetailView: View {
    private var detail: Tag?

    init(_ detail: Tag?) {
        self.detail = detail
    }

    var body: some View {
        Group {
            if let detail {
                ItemListView(tag: detail) { yearTag in
                    if detail.type == .yearMonth,
                       let date = detail.items?.first?.date {
                        return Item.descriptor(dateIsSameMonthAs: date)
                    }
                    if detail.type == .content {
                        return Item.descriptor(content: detail.name,
                                               year: yearTag.name)
                    }
                    return Item.descriptor(predicate: .false)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                CreateButton()
            }
            ToolbarItem(placement: .status) {
                Text("\(detail?.items?.count ?? .zero) Items")
                    .font(.footnote)
            }
        }
    }
}
