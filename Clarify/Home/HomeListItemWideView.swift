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
                .frame(width: .conponentS)
            Divider()
            Text(item.content)
                .font(.headline)
            Spacer()
            Divider()
            HStack {
                Text(convert(Int(item.income)))
                    .frame(width: .conponentM)
                Divider()
                Text(convert(Int(item.expenditure)))
                    .frame(width: .conponentM)
            }.foregroundColor(.secondary)
            Divider()
            Text(convert(item.balance))
                .frame(width: .conponentL)
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
