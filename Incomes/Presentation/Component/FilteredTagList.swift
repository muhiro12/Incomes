//
//  FilteredTagList.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/26.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct FilteredTagList {
    @Query private var tags: [Tag]

    @Binding private var name: String

    init(content: Binding<String>) {
        _tags = Query(filter: Tag.predicate(type: .content))
        _name = content
    }

    init(category: Binding<String>) {
        _tags = Query(filter: Tag.predicate(type: .category))
        _name = category
    }
}

extension FilteredTagList: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(filteredTags) { tag in
                    Button(tag.name) {
                        name = tag.name
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

private extension FilteredTagList {
    var filteredTags: [Tag] {
        let filtered = tags.filter {
            $0.name.lowercased().contains(name.lowercased())
        }
        return filtered.isNotEmpty ? filtered : tags
    }
}

#Preview {
    ModelPreview { (_: Tag) in
        FilteredTagList(category: .constant(.empty))
    }
}
