//
//  TagNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct TagNavigationView: View {
    @State private var tag: TagEntity?

    private let tagType: TagType

    init(tagType: TagType) {
        self.tagType = tagType
    }

    var body: some View {
        NavigationSplitView {
            TagListView(tagType: tagType, selection: $tag)
        } detail: {
            if let tag {
                ItemListGroup()
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
