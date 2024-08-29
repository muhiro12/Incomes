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

    @State private var content: MainSidebarItem?
    @State private var detail: Tag?
}

extension MainNavigationView: View {
    var body: some View {
        NavigationSplitView {
            MainNavigationSidebarView(selection: $content)
        } content: {
            MainNavigationContentView(content, selection: $detail)
        } detail: {
            MainNavigationDetailView(detail)
        }
        .onAppear {
            content = .home
            detail = try? tagService.tag(Tag.descriptor(dateIsSameMonthAs: .now))
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationView()
    }
}
