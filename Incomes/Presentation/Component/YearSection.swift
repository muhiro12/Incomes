//
//  YearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct YearSection: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @State private var isPresentedToAlert = false

    let items: [Item]

    var body: some View {
        Section(content: {
            ForEach(Dictionary(grouping: items) {
                $0.date.stringValue(.yyyyMMM)
            }.sorted {
                $0.key > $1.key
            } .identified) { element in
                NavigationLink(
                    destination:
                        ItemListView(
                            title: element.value.value.first!.date.stringValue(.yyyyMMM),
                            predicate: .init(dateBetweenMonthFor: element.value.value.first!.date))) {
                    Text(element.value.key)
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
            Text(items.first!.date.stringValue(.yyyy))
        })
    }
}

struct YearSection_Previews: PreviewProvider {
    static var previews: some View {
        YearSection(items: [])
    }
}
