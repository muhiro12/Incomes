//
//  IncomesNavigationSplitView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/23.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct IncomesNavigationSplitView<Root: View> {
    @Environment(\.modelContext)
    private var context

    @Binding private var contentID: Tag.ID?
    @Binding private var detailID: Item.ID?

    private let root: () -> Root

    init(contentID: Binding<Tag.ID?>, detailID: Binding<Item.ID?>, @ViewBuilder root: @escaping () -> Root) {
        self.root = root
        _contentID = contentID
        _detailID = detailID
    }
}

extension IncomesNavigationSplitView: View {
    var body: some View {
        NavigationSplitView {
            root()
        } content: {
            if let contentID,
               let tag = try? TagService(context: context).tag(predicate: Tag.predicate(id: contentID)) {
                ItemListView(
                    tag: tag,
                    predicate: {
                        if tag.type == .yearMonth,
                           let date = tag.items?.first?.date {
                            return Item.predicate(dateIsSameMonthAs: date)
                        }
                        if tag.type == .content {
                            return Item.predicate(contentIs: tag.name)
                        }
                        return .false
                    }(),
                    detailID: $detailID
                )
                .id(contentID)
            }
        } detail: {
            if let detailID,
               let item = try? ItemService(context: context).item(predicate: Item.predicate(id: detailID)) {
                ItemFormView(detail: item)
                    .id(detailID)
            }
        }
    }
}

#Preview {
    IncomesNavigationSplitView(contentID: .constant(nil), detailID: .constant(nil)) {
        Box()
    }
}
