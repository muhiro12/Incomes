//
//  TagItemListSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import SwiftData
import SwiftUI

struct TagItemListSection {
    @Environment(Tag.self)
    private var tag
    @Environment(ItemService.self)
    private var itemService

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let yearString: String

    init(yearString: String) {
        self.yearString = yearString
    }
}

extension TagItemListSection: View {
    var body: some View {
        Section {
            ForEach(items) {
                ListItem()
                    .environment($0)
            }
            .onDelete {
                willDeleteItems = $0.map { items[$0] }
                isPresentedToAlert = true
            }
        } header: {
            Text(yearString.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? .empty)
        }
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(
                title: Text("Are you sure you want to delete this item?"),
                buttons: [
                    .destructive(Text("Delete")) {
                        do {
                            try itemService.delete(items: willDeleteItems)
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    },
                    .cancel {
                        willDeleteItems = []
                    }
                ]
            )
        }
    }
}

private extension TagItemListSection {
    var items: [Item] {
        tag.items.orEmpty.filter {
            $0.year?.name == yearString
        }.sorted()
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            TagItemListSection(yearString: Date.now.stringValueWithoutLocale(.yyyy))
                .environment(preview.tags.first { $0.type == .category })
        }
    }
}
