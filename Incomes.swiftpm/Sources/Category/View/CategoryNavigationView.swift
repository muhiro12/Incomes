//
//  CategoryNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI
import SwiftUtilities

struct CategoryNavigationView: View {
    @Binding private var tab: MainTab?

    @State private var path: IncomesPath?

    init(selection: Binding<MainTab?> = .constant(nil)) {
        _tab = selection
    }

    var body: some View {
        NavigationSplitView {
            CategoryListView(selection: $path)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Menu {
                            ForEach(MainTab.allCases) { tab in
                                Button {
                                    withAnimation {
                                        self.tab = tab
                                    }
                                } label: {
                                    tab.label
                                }
                            }
                        } label: {
                            Label {
                                Text("Menu")
                            } icon: {
                                Image(systemName: "list.bullet")
                            }
                        }
                    }
                }
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
        CategoryNavigationView()
    }
}
