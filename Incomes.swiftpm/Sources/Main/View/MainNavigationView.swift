//
//  MainNavigationView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/23.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct MainNavigationView {
    @Environment(TagService.self)
    private var tagService

    @State private var content: IncomesPath?
    @State private var detail: IncomesPath?
}

extension MainNavigationView: View {
    var body: some View {
        NavigationSplitView {
            MainNavigationSidebarView()
                .environment(\.pathSelection, $content)
        } content: {
            MainNavigationContentView(content)
                .environment(\.pathSelection, $detail)
        } detail: {
            MainNavigationDetailView(detail)
        }
        .task {
            content = .home
            if let tag = try? tagService.tag(Tag.descriptor(dateIsSameMonthAs: .now)) {
                detail = .itemList(tag)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationView()
    }
}
