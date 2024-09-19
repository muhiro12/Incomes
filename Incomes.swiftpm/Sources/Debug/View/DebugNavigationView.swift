//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct DebugNavigationView: View {
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            DebugListView(selection: $path)
        } detail: {
            NavigationStack {
                path?.view
                    .incomesNavigationDestination()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DebugNavigationView()
    }
}
