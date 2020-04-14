//
//  ListItemWideView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemWideView: View {
    private let item: ListItem

    init(of item: ListItem) {
        self.item = item
    }

    var body: some View {
        HStack {
            Text(item.date.monthAndDay)
                .frame(width: .conponentS)
            Divider()
            Text(item.content)
                .font(.headline)
            Spacer()
            Divider()
            HStack {
                Text(item.income.asCurrency.string)
                    .frame(width: .conponentM)
                Divider()
                Text(item.expenditure.asMinusCurrency.string)
                    .frame(width: .conponentM)
            }.foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency.string)
                .frame(width: .conponentL)
                .foregroundColor(item.balance >= 0 ? .primary : .red)
        }
    }
}

struct ListItemWideView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemWideView(of:
            ListItem(id: UUID(),
                     date: Date(),
                     content: "Content",
                     income: 999999,
                     expenditure: 99999,
                     balance: 9999999)
        )
    }
}
