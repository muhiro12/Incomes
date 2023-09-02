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
    @State private var isPresentedToSettings = false

    @Query private var items: [Item]
}

extension HomeView: View {
    var body: some View {
        List {
            ForEach(sections) {
                YearSection(startOfYear: $0.section, items: $0.items)
                Advertisement(type: .native(.small))
            }
        }
        .toolbar {
            Button(action: {
                isPresentedToSettings = true
            }, label: {
                Image.settings
                    .iconFrameM()
            })
        }
        .sheet(isPresented: $isPresentedToSettings) {
            SettingsView()
        }
        .id(UUID())
        .navigationBarTitle(.localized(.homeTitle))
        .listStyle(.sidebar)
    }
}

private extension HomeView {
    var sections: [SectionedItems<Date>] {
        ItemService.groupByYear(items: items)
    }
}

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        HomeView()
    }
}
