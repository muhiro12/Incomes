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
            $0.date.stringValue(.yyyy)
        }.forEach { items in
            sectionItemsArray.append(
                SectionItems(key: items.key,
                             value: items.grouped(sortOption: .date) {
                                $0.date.stringValue(.yyyyMMM)
                    }
            ))
        }
        return sectionItemsArray
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sections) { section in
                    SectionView(section: section)
                }
            }.selectedListStyle()
                .navigationBarTitle(LocalizableStrings.homeTitle.localized)
                .navigationBarItems(trailing:
                    Button(action: presentToSetting) {
                        Image.settings
                            .iconFrameM()
                    }
            ).sheet(isPresented: $isPresentedToSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - private

private extension HomeView {
    func presentToSetting() {
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
