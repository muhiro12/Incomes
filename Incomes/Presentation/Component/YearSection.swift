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

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Query private var tags: [Tag]

    @State private var isExpanded = true
    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String

    init(yearTag: Tag) {
        title = yearTag.displayName
        _tags = Query(filter: Tag.predicate(year: yearTag.name),
                      sort: Tag.sortDescriptors(order: .reverse))
        _isExpanded = .init(
            initialValue: yearTag.name == Date.now.stringValueWithoutLocale(.yyyy)
        )
    }
}

extension YearSection: View {
    var body: some View {
        Group {
            Section(title, isExpanded: $isExpanded) {
                ForEach(tags) {
                    Text($0.items?.first?.date.stringValue(.yyyyMMM) ?? .empty)
                }.onDelete {
                    isPresentedToAlert = true
                    willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
                }
            }
            if !isSubscribeOn && isExpanded {
                Section {
                    Advertisement(type: .native(.small))
                }
            }
        }
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(
                title: Text("Are you sure you want to delete this item?"),
                buttons: [
                    .destructive(Text("Delete")) {
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
    ModelPreview { (_: Tag) in
        ListPreview {
            YearSection(yearTag: {
                let tag = Tag()
                tag.set(name: Date.now.stringValueWithoutLocale(.yyyy),
                        typeID: Tag.TagType.year.rawValue)
                return tag
            }())
        }
    }
}
