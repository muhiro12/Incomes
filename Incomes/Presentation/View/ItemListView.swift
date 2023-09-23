//
//  ItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ItemListView {
    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Binding private var detailID: Item.ID?

    private let title: String
    private let yearTags: [Tag]
    private let predicate: Predicate<Item>

    init(tag: Tag, predicate: Predicate<Item>, detailID: Binding<Item.ID?>) {
        self.title = tag.name
        self.yearTags = Set(
            tag.items?.compactMap {
                $0.tags?.first {
                    $0.type == .year
                }
            } ?? []
        ).sorted {
            $0.name > $1.name
        }
        self.predicate = predicate
        _detailID = detailID
    }
}

extension ItemListView: View {
    var body: some View {
        List(selection: $detailID) {
            ForEach(yearTags, id: \.self) {
                ItemListYearSection(yearTag: $0, predicate: predicate)
                if !isSubscribeOn {
                    Advertisement(type: .native(.medium))
                }
            }
        }
        .navigationBarTitle(title)
    }
}

#Preview {
    ModelPreview { tag in
        NavigationStack {
            ItemListView(tag: tag,
                         predicate: .true,
                         detailID: .constant(nil))
        }
    }
}
