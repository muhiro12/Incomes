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

    @State private var tagID: Tag.ID?
    @State private var itemID: Item.ID?

    @State private var isPresentedToSettings = false
}

extension HomeView: View {
    var body: some View {
        NavigationSplitView {
            List(selection: $tagID) {
                ForEach(tags) {
                    YearSection(yearTag: $0)
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
            .navigationBarTitle(.localized(.homeTitle))
        } content: {
            if let tagID,
               let tag = try? TagService(context: context).tag(predicate: Tag.predicate(id: tagID)),
               let date = tag.items?.first?.date {
                ItemListView(tag: tag,
                             predicate: Item.predicate(dateIsSameMonthAs: date),
                             itemID: $itemID)
            }
        } detail: {
            if let itemID,
               let item = try? ItemService(context: context).item(predicate: Item.predicate(id: itemID)) {
                ItemDetailView(of: item)
            }
        }
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        HomeView()
    }
}
