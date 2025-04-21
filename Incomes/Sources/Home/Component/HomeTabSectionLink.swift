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
        NavigationLink(value: IncomesPath.year(yearTag)) {
            VStack(alignment: .leading) {
                Text(yearTag.displayName)
                    .font(.title.bold())
                HStack {
                    Text("Total Income")
                    Spacer()
                    Text(yearTag.items.orEmpty.reduce(.zero) { $0 + $1.income }.asCurrency)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up")
                        .foregroundStyle(.tint)
                }
                .padding(.leading, .spaceL)
                HStack {
                    Text("Total Outgo")
                    Spacer()
                    Text(yearTag.items.orEmpty.reduce(.zero) { $0 + $1.outgo }.asMinusCurrency)
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
            HomeTabSectionLink()
                .environment(preview.tags.first { $0.type == .year })
        }
    }
}
