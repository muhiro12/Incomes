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
    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Query(filter: Tag.predicate(for: .year), sort: Tag.sortDescriptors())
    private var tags: [Tag]

    @State private var isPresentedToSettings = false
}

extension HomeView: View {
    var body: some View {
        List {
            ForEach(tags.reversed()) {
                YearSection(year: $0.name, items: $0.items ?? [])
                if !isSubscribeOn {
                    Advertisement(type: .native(.small))
                }
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

#Preview {
    ModelsPreview { (_: [Tag]) in
        HomeView()
    }
}
