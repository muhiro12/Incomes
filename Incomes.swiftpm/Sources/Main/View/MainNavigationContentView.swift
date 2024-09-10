//
//  MainNavigationContentView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/29/24.
//

import SwiftUI

struct MainNavigationContentView: View {
    private var content: IncomesPath?

    init(_ content: IncomesPath?) {
        self.content = content
    }

    var body: some View {
        content?.view
    }
}
