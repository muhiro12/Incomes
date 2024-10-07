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
}

extension TagItemListSection: View {
    var body: some View {
        Section {
            ForEach(tag.items.orEmpty) {
                ListItem()
                    .environment($0)
            }
            .onDelete {
                willDeleteItems = $0.map { tag.items.orEmpty[$0] }
                isPresentedToAlert = true
            }
        } header: {
            Text(tag.displayName)
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

#Preview {
    IncomesPreview { preview in
        List {
            TagItemListSection()
                .environment(preview.tags.first { $0.type == .category })
        }
    }
}
