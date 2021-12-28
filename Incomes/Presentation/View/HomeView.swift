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

    let items: [Item]

    private var sections: [(String, [Item])] {
        //        var sectionItemsArray: [SectionItems] = []
        //        items.grouped {
        //            $0.date.unwrapped.stringValue(.yyyy)
        //        }.forEach { items in
        //            sectionItemsArray.append(
        //                SectionItems(key: items.key,
        //                             value: items.grouped(by: {
        //                                $0.date.unwrapped.stringValue(.yyyyMMM)
        //                             }, sortOption: .date)
        //                ))
        //        }
        //        return sectionItemsArray
        return []
    }

    var body: some View {
        NavigationView {
            List {
                //                ForEach(sections) { section in
                //                    SectionView(section: section)
                //                }
            }.selectedListStyle()
            .navigationBarTitle(.localized(.homeTitle))
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
