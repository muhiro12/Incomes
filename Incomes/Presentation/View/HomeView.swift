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
    @Query(filter: Tag.predicate(type: .year), sort: Tag.sortDescriptors(order: .reverse))
    private var tags: [Tag]

    @Binding private var selection: Tag.ID?

    init(selection: Binding<Tag.ID?>) {
        _selection = selection
    }
}

extension HomeView: View {
    var body: some View {
        List(tags, selection: $selection) {
            YearSection(yearTag: $0)
        }
        .navigationBarTitle(.localized(.homeTitle))
        .listStyle(.sidebar)
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        NavigationStackPreview {
            HomeView(selection: .constant(nil))
        }
    }
}
