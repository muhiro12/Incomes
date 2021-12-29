//
//  HomeView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var isPresentedToSettings = false

    var body: some View {
        List {
            ForEach(Dictionary(grouping: items) {
                $0.date.stringValue(.yyyy)
            }.sorted {
                $0.key > $1.key
            }.identified) {
                YearSection(items: $0.value.value)
            }
        }.selectedListStyle()
        .navigationBarTitle(.localized(.homeTitle))
        .navigationBarItems(
            trailing: Button(action: {
                isPresentedToSettings = true
            }, label: {
                Image.settings
                    .iconFrameM()
            }))
        .sheet(isPresented: $isPresentedToSettings) {
            SettingsView()
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
