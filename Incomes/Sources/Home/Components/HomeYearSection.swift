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

    @Query private var yearMonthTags: [Tag]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    private let navigateToRoute: (IncomesRoute) -> Void

    init(
        yearTag: Tag,
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
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
                    navigateToRoute(monthRoute)
                } label: {
                    TagSummaryRow()
                        .environment(tag)
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

        let normalizedName = yearMonthTag.name.replacingOccurrences(of: "-", with: "")
        guard normalizedName.count == 6,
              let year = Int(String(normalizedName.prefix(4))),
              let month = Int(String(normalizedName.suffix(2))),
              1...9_999 ~= year,
              1...12 ~= month else {
            return nil
        }

        return .month(year: year, month: month)
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        HomeYearSection(
            yearTag: tags
                .first { tag in
                    tag.name == Date.now.stringValueWithoutLocale(.yyyy)
                }!
        )
    }
}
