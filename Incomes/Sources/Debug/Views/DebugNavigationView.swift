//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct DebugNavigationView: View {
    @State private var tag: Tag?

    var body: some View {
        NavigationSplitView {
            DebugListView(selection: $tag)
        } detail: {
            if let tag {
                ItemListGroup()
                    .environment(tag)
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    DebugNavigationView()
}
