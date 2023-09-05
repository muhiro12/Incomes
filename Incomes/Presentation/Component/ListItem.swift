//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItem {
    @Environment(\.modelContext)
    private var context

    @State private var isPresentedToEdit = false

    private let item: Item

    init(of item: Item) {
        self.item = item
    }
}

extension ListItem: View {
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width < .portraitModeMaxWidth {
                NarrowListItem(of: item)
            } else {
                WideListItem(of: item)
            }
        }
        .sheet(isPresented: $isPresentedToEdit) {
            EditView(of: item)
                .environment(\.modelContext, context)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: presentToEdit)
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - private

private extension ListItem {
    func presentToEdit() {
        isPresentedToEdit = true
    }
}

#Preview {
    ListItem(of: PreviewData.item)
}

#Preview(traits: .landscapeLeft) {
    ListItem(of: PreviewData.item)
}
