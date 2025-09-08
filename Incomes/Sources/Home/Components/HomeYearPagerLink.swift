//
//  HomeYearPagerLink.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/8/24.
//

import SwiftUI

struct HomeYearPagerLink {
    @Environment(Tag.self)
    private var yearTag
}

extension HomeYearPagerLink: View {
    var body: some View {
        let items = yearTag.items.orEmpty
        let income = items.reduce(.zero) { $0 + $1.income }
        let outgo = items.reduce(.zero) { $0 + $1.outgo }
        NavigationLink(value: yearTag) {
            VStack(alignment: .leading) {
                Text(yearTag.displayName)
                    .font(.title.bold())
                HStack {
                    Text("Total Income")
                    Spacer()
                    Text(income.asCurrency)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up")
                        .foregroundStyle(.tint)
                }
                .padding(.leading, .spaceL)
                HStack {
                    Text("Total Outgo")
                    Spacer()
                    Text(outgo.asMinusCurrency)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.red)
                }
                .padding(.leading, .spaceL)
            }
            .contentShape(.rect)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            if let tag = preview.tags.first(where: { $0.type == .year }) {
                HomeYearPagerLink()
                    .environment(tag)
            }
        }
    }
}
