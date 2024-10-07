//
//  CategoryListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct CategoryListView {
    @Environment(ItemService.self)
    private var itemService

    @Query(.tags(.typeIs(.category)))
    private var tags: [Tag]

    @Binding private var path: IncomesPath?

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems = [Item]()

    init(selection: Binding<IncomesPath?> = .constant(nil)) {
        _path = selection
    }
}

extension CategoryListView: View {
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
        .listStyle(.sidebar)
        .navigationTitle(Text("Category"))
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
        CategoryListView()
    }
}
