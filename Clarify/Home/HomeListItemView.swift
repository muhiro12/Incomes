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
            Text(DateConverter().convertToDay(item.date))
                .frame(width: 60)
            Divider()
            Text(item.content ?? "")
            Spacer()
            Divider()
            Text(convert(Int(item.income)))
                .frame(width: 80)
            Divider()
            Text(convert(Int(item.expenditure)))
                .frame(width: 80)
            Divider()
            Text(convert(sum))
                .frame(width: 100)
                .foregroundColor(sum >= 0 ? .black : .red)
        }
    }

    private func convert(_ int: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: int)) ?? ""
    }
}

struct HomeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListItemView(item: Item(), sum: 0)
    }
}
