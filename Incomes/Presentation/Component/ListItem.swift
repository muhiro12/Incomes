//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItem: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresentedToEdit = false

    private let item: Item

    init(of item: Item) {
        self.item = item
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 500 {
                WideListItem(of: self.item)
            } else {
                NarrowListItem(of: self.item)
            }
        }.sheet(isPresented: $isPresentedToEdit) {
            EditView(of: self.item)
                .environment(\.managedObjectContext, self.context)
        }.contentShape(Rectangle())
        .onTapGesture(perform: presentToEdit)
    }
}

// MARK: - private

private extension ListItem {
    func presentToEdit() {
        isPresentedToEdit = true
    }
}

#if DEBUG
struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(of: PreviewData.item)
    }
}
#endif
