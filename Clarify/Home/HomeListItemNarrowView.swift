//
//  HomeListItemNarrowView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListItemNarrowView: HomeListItemView {
    var item: HomeListItem

    var body: some View {
        HStack {
            Text(DateConverter().convertToDay(item.date))
                .frame(width: 60)
            Divider()
            VStack(spacing: 0) {
                Text(item.content)
                    .font(.headline)
                HStack {
                    Spacer()
                    Text(self.convert(Int(self.item.income)))
                        .frame(width: 60)
                    Divider()
                    Text(self.convert(Int(self.item.expenditure)))
                        .frame(width: 60)
                    Spacer()
                }.font(.caption)
                    .foregroundColor(.secondary)

            }
            Divider()
            Text(convert(item.balance))
                .frame(width: 100)
                .foregroundColor(item.balance >= 0 ? .primary : .red)
        }
    }
}

struct HomeListItemNarrowView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListItemNarrowView(item: HomeListItem(date: Date(),
                                                  content: "Content",
                                                  income: 999999,
                                                  expenditure: 99999,
                                                  balance: 9999999))
    }
}
