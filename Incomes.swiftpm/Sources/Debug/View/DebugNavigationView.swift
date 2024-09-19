//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct DebugNavigationView: View {
    @State private var detail: IncomesPath?

    var body: some View {
        NavigationSplitView {
            DebugView()
                .environment(\.pathSelection, $detail)
        } detail: {
            NavigationStack {
                detail?.view
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
