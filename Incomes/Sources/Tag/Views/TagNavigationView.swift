//
//  TagNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct TagNavigationView: View {
    @State private var path: IncomesPath?

    private let tagType: TagType

    init(tagType: TagType) {
        self.tagType = tagType
    }

    var body: some View {
        NavigationSplitView {
            TagListView(tagType: tagType, selection: $path)
        } detail: {
            if case .itemList(let tag) = path {
                ItemListView()
                    .environment(tag)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        TagNavigationView(tagType: .category)
    }
}
