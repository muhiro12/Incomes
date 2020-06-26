//
//  HomeView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @State private var isPresentedToSettings = false

    let items: ListItems

    private var sections: [SectionItems] {
        var sectionItemsArray: [SectionItems] = []
        items.grouped {
            $0.date.year
        }.forEach { items in
            sectionItemsArray.append(
                SectionItems(key: items.key,
                             value: items.grouped {
                                $0.date.yearAndMonth
                    }
            ))
        }
        return sectionItemsArray
    }

    var body: some View {
        NavigationView {
            Form {
                ForEach(sections) { section in
                    SectionView(section: section)
                }
            }.selectedListStyle()
                .navigationBarTitle(String.homeTitle)
                .navigationBarItems(trailing:
                    Button(action: presentToSetting) {
                        Image(systemName: .settingsIcon)
                            .iconFrame()
                    }
            ).sheet(isPresented: $isPresentedToSettings) {
                SettingsView()
            }
        }
    }

    private func presentToSetting() {
        isPresentedToSettings = true
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(items: PreviewData.listItems)
    }
}
#endif
