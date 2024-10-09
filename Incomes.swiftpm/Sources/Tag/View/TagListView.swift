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

    @State private var isPresentedToAlert = false
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
                    Text(tag.displayName)
                }
            }
            .onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
            }
        }
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
                CreateButton()
            }
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
    IncomesPreview { _ in
        TagListView(tagType: .content)
    }
}

#Preview {
    IncomesPreview { _ in
        TagListView(tagType: .category)
    }
}
