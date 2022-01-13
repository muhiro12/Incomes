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
        sortDescriptors: [.init(keyPath: \Item.year, ascending: false)],
        animation: .default)
    private var sections: SectionedFetchResults<Date, Item>

    @State
    private var isPresentedToSettings = false

    var body: some View {
        List {
            ForEach(sections) {
                YearSection(year: $0.id, items: $0.map { $0 })
            }
        }.toolbar {
            Button(action: {
                isPresentedToSettings = true
            }, label: {
                Image.settings
                    .iconFrameM()
            })
        }.sheet(isPresented: $isPresentedToSettings) {
            SettingsView()
        }.navigationBarTitle(.localized(.homeTitle))
        .listStyle(.sidebar)
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
