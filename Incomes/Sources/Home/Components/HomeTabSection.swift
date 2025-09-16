//
//  HomeTabSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeTabSection: View {
    @Environment(Tag.self)
    private var yearTag

    var body: some View {
        let items = yearTag.items.orEmpty
        let income = items.reduce(.zero) { $0 + $1.income }
        let outgo = items.reduce(.zero) { $0 + $1.outgo }

        Section("Summary") {
            NavigationLink(value: yearTag) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Total Income")
                        Spacer()
                        Text(income.asCurrency)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.up")
                            .foregroundStyle(.tint)
                    }
                    .padding(.vertical)
                    HStack {
                        Text("Total Outgo")
                        Spacer()
                        Text(outgo.asMinusCurrency)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            List {
                HomeTabSection()
                    .environment(preview.tags.first { $0.type == .year })
            }
        }
    }
}
