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
    @Environment(\.modelContext)
    private var context

    @Query private var tags: [Tag]

    @State private var isExpanded = true
    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let tag: Tag

    init(yearTag: Tag) {
        tag = yearTag
        _tags = Query(filter: Tag.predicate(year: yearTag.name),
                      sort: Tag.sortDescriptors(order: .reverse))
        _isExpanded = .init(
            initialValue: tag.name == Date.now.stringValueWithoutLocale(.yyyy)
        )
    }
}

extension YearSection: View {
    var body: some View {
        Section(tag.name, isExpanded: $isExpanded) {
            ForEach(tags) {
                Text($0.items?.first?.date.stringValue(.yyyyMMM) ?? .empty)
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
            }
        }
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(
                title: Text(.localized(.deleteConfirm)),
                buttons: [
                    .destructive(Text(.localized(.delete))) {
                        do {
                            try ItemService(context: context).delete(items: willDeleteItems)
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
    ModelPreview { tag in
        ListPreview {
            YearSection(yearTag: tag)
        }
    }
}
