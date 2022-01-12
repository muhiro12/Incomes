//
//  YearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct YearSection: View {
    @State
    private var isPresentedToAlert = false

    let title: String
    let items: [Item]

    var body: some View {
        Section(content: {
            ForEach(Dictionary(grouping: items) {
                Calendar.current.startOfMonth(for: $0.date)
            }.sorted {
                $0.key > $1.key
            }.identified) { element in
                NavigationLink(
                    destination:
                        ItemListView(
                            title: element.value.key.stringValue(.yyyyMMM),
                            predicate: .init(dateIsSameMonthAs: element.value.key))) {
                    Text(element.value.key.stringValue(.yyyyMMM))
                }
            }.onDelete { _ in
                isPresentedToAlert = true
            }.actionSheet(isPresented: $isPresentedToAlert) {
                ActionSheet(
                    title: Text(.localized(.deleteConfirm)),
                    buttons: [
                        .destructive(Text(.localized(.delete))) {
                            // TODO: Delete item
                        },
                        .cancel()])
            }
        }, header: {
            Text(title)
        })
    }
}

#if DEBUG
struct YearSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            YearSection(title: "2023",
                        items: PreviewData().items.filter {
                            $0.year == "2023"
                        })
        }
    }
}
#endif
