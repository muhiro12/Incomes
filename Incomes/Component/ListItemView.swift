//
//  ListItemView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresentedToEdit = false

    private let item: ListItem

    init(of item: ListItem) {
        self.item = item
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 500 {
                ListItemWideView(of: self.item)
            } else {
                ListItemNarrowView(of: self.item)
            }
        }.sheet(isPresented: $isPresentedToEdit) {
            EditView(of: self.item)
                .environment(\.managedObjectContext, self.context)
        }.contentShape(Rectangle())
            .onTapGesture(perform: presentToEdit)
    }
}

// MARK: - private

private extension ListItemView {
    func presentToEdit() {
        isPresentedToEdit = true
    }
}

#if DEBUG
struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(of: PreviewData.listItem)
    }
}
#endif
