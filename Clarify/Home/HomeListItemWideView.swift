//
//  HomeListItemWideView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListItemWideView: View {
    let item: HomeListItem

    var body: some View {
        HStack {
            Text(item.date.MMdd)
                .frame(width: .conponentS)
            Divider()
            Text(item.content)
                .font(.headline)
            Spacer()
            Divider()
            HStack {
                Text(item.income.asCurrency)
                    .frame(width: .conponentM)
                Divider()
                Text(item.expenditure.asCurrency)
                    .frame(width: .conponentM)
            }.foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency)
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
