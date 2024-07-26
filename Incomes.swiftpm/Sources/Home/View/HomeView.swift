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
    @Query(Tag.descriptor(type: .year, order: .reverse))
    private var tags: [Tag]

    @Binding private var selection: Tag.ID?

    init(selection: Binding<Tag.ID?>) {
        _selection = selection
    }
}

extension HomeView: View {
    var body: some View {
        List(tags, selection: $selection) { tag in
            if tag.items.orEmpty.isNotEmpty {
                YearSection(yearTag: tag)
            }
        }
        .navigationTitle(Text("Home"))
        .listStyle(.sidebar)
    }
}

#Preview {
    IncomesPreview { _ in
        HomeView(selection: .constant(nil))
    }
}
