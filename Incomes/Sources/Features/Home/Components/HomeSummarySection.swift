//
//  HomeSummarySection.swift
//  Incomes
//
//  Created by Codex on 2026/06/13.
//

import SwiftUI

struct HomeSummarySection: View {
    let navigateToRoute: (IncomesRoute) -> Void

    var body: some View {
        Section("Summary") {
            HomeSummaryButton(
                navigateToRoute: navigateToRoute
            )
        }
    }
}
