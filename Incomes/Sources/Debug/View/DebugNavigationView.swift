//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

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
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DebugNavigationView()
    }
}
