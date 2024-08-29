//
//  MainNavigationContentView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/29/24.
//

import SwiftUI

struct MainNavigationContentView: View {
    @Binding private var selection: Tag?

    private var content: MainSidebarItem?

    init(_ content: MainSidebarItem?, selection: Binding<Tag?>) {
        self.content = content
        self._selection = selection
    }

    var body: some View {
        Group {
            switch content {
            case .home:
                HomeView(selection: $selection)
            case .category:
                CategoryView(selection: $selection)
            case .debug:
                DebugView()
                    .incomesNavigationDestination()
            case .none:
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem {
                CreateButton()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date().stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
    }
}
