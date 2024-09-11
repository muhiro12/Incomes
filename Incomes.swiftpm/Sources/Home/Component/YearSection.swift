//
//  YearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct YearSection {
    @Environment(ItemService.self)
    private var itemService

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn: Bool

    @Query private var tags: [Tag]

    @State private var isExpanded = true
    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let tag: Tag
    private let title: String

    init(yearTag: Tag) {
        tag = yearTag
        title = yearTag.displayName
        _tags = Query(Tag.descriptor(.yearIs(yearTag.name), order: .reverse))
        _isExpanded = .init(
            initialValue: yearTag.name == Date.now.stringValueWithoutLocale(.yyyy)
        )
    }
}

extension YearSection: View {
    var body: some View {
        Group {
            Section(isExpanded: $isExpanded) {
                ForEach(tags) { tag in
                    if let items = tag.items,
                       let first = items.first {
                        NavigationLink(path: .itemList(tag)) {
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
            } header: {
                NavigationLink(path: .year(tag)) {
                    Text(title)
                }
            }
            if !isSubscribeOn, isExpanded {
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
                ])
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            YearSection(
                yearTag: preview.tags.first { $0.type == .year }!
            )
        }
    }
}
