//
//  MainNavigationDetailView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/29/24.
//

import SwiftUI

struct MainNavigationDetailView: View {
    private var detail: IncomesPath?

    init(_ detail: IncomesPath?) {
        self.detail = detail
    }

    var body: some View {
        NavigationStack {
            detail?.view
                .incomesNavigationDestination()
        }
    }
}
