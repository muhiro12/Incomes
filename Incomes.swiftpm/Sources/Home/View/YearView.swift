//
//  YearView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/30/24.
//

import SwiftUI

struct YearView: View {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let date: Date

    init(date: Date) {
        self.date = date
    }

    var body: some View {
        List {
            ChartSections(.items(.dateIsSameYearAs(date)))
        }
        .navigationTitle(date.stringValue(.yyyy))
    }
}

#Preview {
    IncomesPreview { _ in
        YearView(date: .now)
    }
}
