//
//  HomeYearSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import SwiftData
import SwiftUI

struct HomeYearSection {
    @Environment(ItemService.self)
    private var itemService

    @Query private var yearMonthTags: [Tag]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    init(yearTag: Tag) {
        _yearMonthTags = Query(.tags(.nameStartsWith(yearTag.name, type: .yearMonth), order: .reverse))
    }
}

extension HomeYearSection: View {
    var body: some View {
        Section {
            ForEach(yearMonthTags) { yearMonthTag in
                if let items = yearMonthTag.items {
                    NavigationLink(value: IncomesPath.itemList(yearMonthTag)) {
                        Text(yearMonthTag.displayName)
                            .foregroundStyle(
                                items.contains(where: \.balance.isMinus) ? .red : .primary
                            )
                            .bold(yearMonthTag.name == Date.now.stringValueWithoutLocale(.yyyyMM))
                    }
                }
            }.onDelete {
                Haptic.warning.impact()
                isDialogPresented = true
                willDeleteItems = $0.flatMap { yearMonthTags[$0].items ?? [] }
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try itemService.delete(items: willDeleteItems)
                    Haptic.success.impact()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
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
    IncomesPreview { preview in
        List {
            HomeYearSection(
                yearTag: preview.tags.first {
                    $0.name == Date.now.stringValueWithoutLocale(.yyyy)
                }!
            )
        }
    }
}
