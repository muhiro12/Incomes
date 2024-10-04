//
//  HomeListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeListView {
    @Environment(ItemService.self)
    private var itemService

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    @Query private var tags: [Tag]

    @Binding private var path: IncomesPath?

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String
    private let date: Date

    init(yearTag: Tag, selection: Binding<IncomesPath?> = .constant(nil)) {
        _tags = Query(.tags(.yearIs(yearTag.name), order: .reverse))
        _path = selection
        title = yearTag.displayName
        date = yearTag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast
    }
}

extension HomeListView: View {
    var body: some View {
        List(selection: $path) {
            Section {
                ForEach(tags) { tag in
                    if let items = tag.items,
                       let first = items.first {
                        NavigationLink(value: IncomesPath.itemList(tag)) {
                            Text(first.date.stringValue(.yyyyMMM))
                                .foregroundStyle(
                                    items.contains {
                                        $0.balance.isMinus
                                    } ? .red : .primary
                                )
                        }
                    }
                }.onDelete {
                    isPresentedToAlert = true
                    willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
                }
            } footer: {
                NavigationLink(value: IncomesPath.year(date)) {
                    Text("See Charts")
                }
            }
            if !isSubscribeOn {
                AdvertisementSection(.small)
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
    IncomesPreview { preview in
        NavigationStack {
            HomeListView(
                yearTag: preview.tags.first { $0.type == .year }!
            )
        }
    }
}
