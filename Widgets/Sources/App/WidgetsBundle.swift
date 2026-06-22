//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        IncomesMonthWidget()
        IncomesMonthNetIncomeWidget()
        IncomesUpcomingWidget()
    }
}
