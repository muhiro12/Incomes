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
    @Environment(\.navigationItemSelection)
    private var navigationItemSelection

    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @Environment(Tag.self)
    private var tag
    @Environment(IncomesTipController.self)
    private var tipController

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    @State private var isRenameSheetPresented = false
    @State private var renamedTag: Tag?
}

extension CategoryItemListView: View {
    var body: some View {
        let currentYearStrings = yearStrings
        let firstYearString = currentYearStrings.first

        List(selection: navigationItemSelection) {
            ForEach(currentYearStrings, id: \.self) { yearString in
                TagItemListSection(
                    yearString: yearString,
                    showsItemDetailTip: yearString == firstYearString
                )
                if !isSubscribeOn {
                    AdvertisementSection(.media)
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle(currentTag.displayName)
        .tagEntityIdentifier(currentTag)
        .task(id: items.count) {
            guard !items.isEmpty else {
                return
            }
            tipController.donateDidViewItemList()
        }
        .sheet(isPresented: $isRenameSheetPresented) {
            CategoryRenameSheet(initialName: currentTag.displayName) { renamed in
                renamedTag = renamed
            }
            .incomesSheetPresentation()
        }
        .toolbar {
            if canRenameCategory {
                ToolbarItem {
                    Button("Rename", systemImage: "pencil") {
                        isRenameSheetPresented = true
                    }
                    .ledgerWriteAccess(owner: ledgerIdentifier)
                }
            }
            ItemCountStatusToolbarItem(count: items.count)
        }
        .toolbar {
            CreateItemToolbarContent()
        }
        .environment(currentTag)
        .onChange(of: tag.persistentModelID) {
            renamedTag = nil
        }
    }
}

private extension CategoryItemListView {
    var currentTag: Tag {
        renamedTag ?? tag
    }

    var canRenameCategory: Bool {
        TagRenameOperations.canRenameCategory(currentTag)
    }

    var items: [Item] {
        TagQueryOperations.items(for: currentTag, ledgerIdentifier: ledgerIdentifier)
    }

    var yearStrings: [String] {
        TagQueryOperations.yearStrings(for: currentTag, ledgerIdentifier: ledgerIdentifier)
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
