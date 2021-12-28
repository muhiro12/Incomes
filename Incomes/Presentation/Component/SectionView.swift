//
//  SectionView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SectionView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresentedToAlert = false
    @State private var indexSet = IndexSet()

    let section: SectionItems

    private var navigationLinks: some View {
        return Spacer()
        //        return ForEach(section.value) { items in
        //            NavigationLink(destination:
        //                            ListView(of: items)
        //                            .navigationBarTitle(items.description)) {
        //                Text(items.description)
        //            }
        //        }.onDelete(perform: presentToAlert)
        //        .actionSheet(isPresented: $isPresentedToAlert) {
        //            ActionSheet(title: Text(.localized(.deleteConfirm)),
        //                        buttons: [
        //                            .destructive(Text(.localized(.delete)),
        //                                         action: delete),
        //                            .cancel()
        //                        ])
        //        }
    }

    var body: some View {
        Section(header: Text(section.key)) {
            navigationLinks
        }
    }
}

// MARK: - private

private extension SectionView {
    func presentToAlert(indexSet: IndexSet) {
        self.indexSet = indexSet
        isPresentedToAlert = true
    }

    func delete() {
        indexSet.forEach {
            section.value[$0].forEach { item in
                Repository.delete(context, item: item)
            }
        }
    }
}

#if DEBUG
struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        SectionView(section: PreviewData.sectionItems)
    }
}
#endif
