//
//  HomeView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @SectionedFetchRequest(
        sectionIdentifier: \Item.year,
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.year, ascending: false),
                          NSSortDescriptor(keyPath: \Item.date, ascending: false)],
        animation: .default)
    private var sections: SectionedFetchResults<String, Item>

    @State
    private var isPresentedToSettings = false

    var body: some View {
        List {
            ForEach(sections) {
                YearSection(title: $0.id, items: $0.map { $0 })
            }
        }.navigationBarTitle(.localized(.homeTitle))
        .toolbar {
            Button(action: {
                isPresentedToSettings = true
            }, label: {
                Image.settings
                    .iconFrameM()
            })
        }.sheet(isPresented: $isPresentedToSettings) {
            SettingsView()
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
