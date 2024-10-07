//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI
import SwiftUtilities

struct DebugNavigationView: View {
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            DebugListView(selection: $path)
        } detail: {
            if case .itemList(let tag) = path {
                ItemListView()
                    .environment(tag)
            } else if case .tag(let tag) = path {
                DebugTagView()
                    .environment(tag)
            } else if case .itemForm(let mode) = path {
                ItemFormView(mode: mode)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DebugNavigationView()
    }
}
