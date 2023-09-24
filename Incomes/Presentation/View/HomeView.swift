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
    @Environment(\.modelContext)
    private var context

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

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
            if !isSubscribeOn {
                Advertisement(type: .native(.small))
            }
        }
        .navigationBarTitle(.localized(.homeTitle))
        .listStyle(.sidebar)
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        NavigationStack {
            HomeView(selection: .constant(nil))
        }
    }
}
