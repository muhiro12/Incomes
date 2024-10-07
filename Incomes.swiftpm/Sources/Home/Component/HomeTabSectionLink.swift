//
//  HomeTabSectionLink.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/8/24.
//

import SwiftUI

struct HomeTabSectionLink {
    @Environment(Tag.self)
    private var yearTag: Tag
}

extension HomeTabSectionLink: View {
    var body: some View {
        NavigationLink(value: IncomesPath.year(yearTag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast)) {
            VStack(alignment: .leading) {
                Text(yearTag.displayName)
                    .font(.title.bold())
                HStack {
                    Spacer()
                    Text("Total Income")
                    Text(yearTag.items.orEmpty.reduce(.zero) { $0 + $1.income }.asCurrency)
                        .foregroundStyle(.tint)
                }
                HStack {
                    Spacer()
                    Text("Total Outgo")
                    Text(yearTag.items.orEmpty.reduce(.zero) { $0 + $1.outgo }.asMinusCurrency)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            HomeTabSectionLink()
                .environment(preview.tags.first { $0.type == .year })
        }
    }
}
