//
//  TagListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct TagListView {
    @Environment(ItemService.self)
    private var itemService

    @Query
    private var tags: [Tag]

    @Binding private var path: IncomesPath?

    @State private var searchText = String.empty
    @State private var isDialogPresented = false
    @State private var willDeleteItems = [Item]()

    private let tagType: Tag.TagType

    init(tagType: Tag.TagType, selection: Binding<IncomesPath?> = .constant(nil)) {
        self.tagType = tagType
        self._tags = .init(.tags(.typeIs(tagType)))
        self._path = selection
    }
}

extension TagListView: View {
    var body: some View {
        List(selection: $path) {
            ForEach(tags) { tag in
                NavigationLink(value: IncomesPath.itemList(tag)) {
                    HStack {
                        Text(tag.displayName)
                        Spacer()
                        Text(tag.items.orEmpty.count.description)
                            .foregroundStyle(.secondary)
                    }
                }
                .hidden(
                    searchText.isNotEmpty
                        && (
                            !tag.name.normalizedContains(searchText)
                                || tag.items.orEmpty.isEmpty
                        )
                )
            }
            .onDelete {
                Haptic.warning.impact()
                isDialogPresented = true
                willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle(Text(tagType == .content ? "Content" : "Category"))
        .toolbar {
            ToolbarItem {
                CreateItemButton()
            }
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try itemService.delete(items: willDeleteItems)
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete \(Set(willDeleteItems.map(\.content)).joined(separator: ", "))")
            }
            Button(role: .cancel) {
                willDeleteItems = []
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            TagListView(tagType: .content)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            TagListView(tagType: .category)
        }
    }
}
