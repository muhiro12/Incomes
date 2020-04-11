//
//  HomeListItemNarrowView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListItemNarrowView: View {
    let item: HomeListItem

    var body: some View {
        HStack {
            Text(DateConverter().convertToDay(item.date))
                .frame(width: .conponentS)
            Divider()
            VStack(spacing: 0) {
                Text(item.content)
                    .font(.headline)
                HStack {
                    Spacer()
                    Text(CurrencyConverter().convert(Int(self.item.income)))
                        .frame(width: .conponentS)
                    Divider()
                    Text(CurrencyConverter().convert(Int(self.item.expenditure)))
                        .frame(width: .conponentS)
                    Spacer()
                }.font(.caption)
                    .foregroundColor(.secondary)

            }
            Divider()
            Text(CurrencyConverter().convert(item.balance))
                .frame(width: .conponentL)
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
