//
//  HomeListItemView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListItemView: View {
    @Environment(\.managedObjectContext) var context

    let item: Item
    let sum: Int

    var body: some View {
        HStack {
            Text(DateConverter().convert(item.date))
                .frame(width: 60)
            Divider()
            Text(item.content ?? "")
            Spacer()
            Divider()
            Text(item.income.description)
                .frame(width: 40)
            Divider()
            Text(item.expenditure.description)
                .frame(width: 40)
                .foregroundColor(.red)
            Divider()
            Text(sum.description)
                .frame(width: 60)
        }
    }
}

struct HomeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListItemView(item: Item(), sum: 0)
    }
}
