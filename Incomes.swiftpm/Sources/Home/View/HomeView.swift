//
//  HomeView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeView {
    @Query(.tags(.typeIs(.year), order: .reverse))
    private var tags: [Tag]

    @Environment(\.pathSelection) private var selection
}

extension HomeView: View {
    var body: some View {
        List(tags, selection: selection) { tag in
            if tag.items.isNotEmpty {
                YearSection(yearTag: tag)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(Text("Home"))
        .toolbar {
            ToolbarItem {
                CreateButton()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        HomeView()
    }
}
