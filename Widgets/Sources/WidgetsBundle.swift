//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Hiromu Nakano on 2025/09/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        IncomesMonthWidget()
        WidgetsControl()
        WidgetsLiveActivity()
    }
}
