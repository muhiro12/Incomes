//
//  HomeYearSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import SwiftData
import SwiftUI

struct HomeYearSection: View {
    @Environment(\.modelContext)
    private var context
    @Environment(IncomesTipController.self)
    private var tipController

    @Query private var yearMonthTags: [Tag]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    private let navigateToRoute: (IncomesRoute) -> Void

    init(
        yearTag: Tag,
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        }
    ) {
        _yearMonthTags = Query(
            .tags(
                .nameStartsWith(yearTag.name, type: .yearMonth),
                order: .reverse
            )
        )
        self.navigateToRoute = navigateToRoute
    }

    var body: some View {
        Section {
            ForEach(yearMonthTags) { tag in
                Button {
                    guard let monthRoute = route(for: tag) else {
                        return
                    }
                    tipController.donateDidOpenMonth()
                    navigateToRoute(monthRoute)
                } label: {
                    TagSummaryRow()
                        .environment(tag)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .onDelete { indices in
                Haptic.warning.impact()
                isDialogPresented = true
                willDeleteItems = TagService.resolveItemsForDeletion(
                    from: yearMonthTags,
                    indices: indices
                )
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try ItemService.delete(
                        context: context,
                        items: willDeleteItems
                    )
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

private extension HomeYearSection {
    func route(for yearMonthTag: Tag) -> IncomesRoute? {
        guard yearMonthTag.type == .yearMonth else {
            return nil
        }
        guard let date = TagService.date(for: yearMonthTag) else {
            return nil
        }
        let calendar = Calendar.current
        return .month(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date)
        )
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        if let yearTag = tags.first(where: { tag in
            tag.name == Date.now.stringValueWithoutLocale(.yyyy)
        }) {
            HomeYearSection(yearTag: yearTag)
        } else {
            EmptyView()
        }
    }
}
