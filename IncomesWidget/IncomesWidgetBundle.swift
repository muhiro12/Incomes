//
//  IncomesWidgetBundle.swift
//  IncomesWidget
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct IncomesWidgetBundle: WidgetBundle {
    var body: some Widget {
        IncomesWidget()
        ThisMonthItemsWidget()
        IncomesWidgetControl()
        IncomesWidgetLiveActivity()
    }
}
