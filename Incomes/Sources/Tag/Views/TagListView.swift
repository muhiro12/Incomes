//
//  TagListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct TagListView: View {
    @Environment(\.modelContext)
    private var context

    @BridgeQuery
    private var tagEntities: [TagEntity]

    @Binding private var path: IncomesPath?

    @State private var searchText = String.empty
    @State private var isDialogPresented = false
    @State private var willDeleteTags = [Tag]()

    private let tagType: TagType

    init(tagType: TagType, selection: Binding<IncomesPath?> = .constant(nil)) {
        self.tagType = tagType
        self._tagEntities = .init(.tags(.typeIs(tagType)))
        self._path = selection
    }

    private var tags: [Tag] {
        tagEntities.compactMap { try? $0.model(in: context) }
    }

    var body: some View {
        List(selection: $path) {
            ForEach(tagEntities) { entity in
                let tag = try? entity.model(in: context)
                NavigationLink(value: IncomesPath.itemList(entity)) {
                    HStack {
                        Text(tag?.displayName ?? "")
                        Spacer()
                        Text(tag?.items.orEmpty.count.description ?? "0")
                            .foregroundStyle(.secondary)
                    }
                }
                .hidden(
                    searchText.isNotEmpty
                        && (
                            !(tag?.name.normalizedContains(searchText) ?? false)
                                || tag?.items.orEmpty.isEmpty ?? true
                        )
                )
            }
            .onDelete { indices in
                Haptic.warning.impact()
                isDialogPresented = true
                willDeleteTags = indices.compactMap {
                    try? tagEntities[$0].model(in: context)
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle(Text(tagType == .content ? "Content" : "Category"))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    let tags = willDeleteTags
                    let items = tags.flatMap {
                        $0.items ?? .empty
                    }
                    try tags
                        .compactMap(TagEntity.init)
                        .forEach {
                            try DeleteTagIntent.perform((container: context.container, tag: $0))
                        }
                    try items.compactMap(ItemEntity.init).forEach {
                        try DeleteItemIntent.perform((container: context.container, item: $0))
                    }
                    willDeleteTags = .empty
                    Haptic.success.impact()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete \(Set(willDeleteTags.map(\.displayName)).joined(separator: ", "))")
            }
            Button(role: .cancel) {
                willDeleteTags = .empty
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete these tags and the items linked to them?")
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
