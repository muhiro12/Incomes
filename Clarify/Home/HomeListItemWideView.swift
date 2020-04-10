//
//  HomeListItemWideView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListItemWideView: HomeListItemView {
    var item: HomeListItem

    var body: some View {
        HStack {
            Text(DateConverter().convertToDay(item.date))
                .frame(width: 60)
            Divider()
            Text(item.content)
            Spacer()
            Divider()
            HStack {
                Text(convert(Int(item.income)))
                    .frame(width: 80)
                Divider()
                Text(convert(Int(item.expenditure)))
                    .frame(width: 80)
            }.foregroundColor(.secondary)
            Divider()
            Text(convert(item.balance))
                .frame(width: 100)
                .foregroundColor(item.balance >= 0 ? .primary : .red)
        }
    }
}

struct HomeListItemWideView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListItemWideView(item: HomeListItem(date: Date(),
                                                content: "Content",
                                                income: 999999,
                                                expenditure: 99999,
                                                balance: 9999999))
    }
}
