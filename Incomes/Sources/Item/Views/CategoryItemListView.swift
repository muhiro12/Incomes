//
//  CategoryItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import MHPlatform
import SwiftData
import SwiftUI

struct CategoryItemListView {
    @Environment(Tag.self)
    private var tag
    @Environment(IncomesTipController.self)
    private var tipController

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    @State private var isRenameSheetPresented = false
}

extension CategoryItemListView: View {
    var body: some View {
        let currentYearStrings = yearStrings
        let firstYearString = currentYearStrings.first

        List {
            ForEach(currentYearStrings, id: \.self) { yearString in
                TagItemListSection(
                    yearString: yearString,
                    showsItemDetailTip: yearString == firstYearString
                )
                if !isSubscribeOn {
                    AdvertisementSection(.medium)
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle(tag.displayName)
        .task(id: items.count) {
            guard !items.isEmpty else {
                return
            }
            tipController.donateDidViewItemList()
        }
        .sheet(isPresented: $isRenameSheetPresented) {
            CategoryRenameSheet(tag: tag)
                .incomesSheetPresentation()
        }
        .toolbar {
            if canRenameCategory {
                ToolbarItem {
                    Button("Rename") {
                        isRenameSheetPresented = true
                    }
                }
            }
            ItemCountStatusToolbarItem(count: items.count)
        }
        .toolbar {
            SpacerToolbarItem(placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
    }
}

private extension CategoryItemListView {
    var canRenameCategory: Bool {
        TagRenameOperations.canRenameCategory(tag)
    }

    var items: [Item] {
        TagQueryOperations.items(for: tag)
    }

    var yearStrings: [String] {
        TagQueryOperations.yearStrings(for: tag)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let tag = tags.first(where: { previewTag in
            previewTag.type == .category
        }) {
            CategoryItemListView()
                .environment(tag)
        }
    }
}
