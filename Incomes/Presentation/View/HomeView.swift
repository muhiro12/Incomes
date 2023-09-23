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

    @Binding private var contentID: Tag.ID?

    @State private var isPresentedToSettings = false

    init(contentID: Binding<Tag.ID?>) {
        _contentID = contentID
    }
}

extension HomeView: View {
    var body: some View {
        List(selection: $contentID) {
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
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        HomeView(contentID: .constant(nil))
    }
}
