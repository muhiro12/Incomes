//
//  IncomesIntent
//  Incomes
//
//  Created by Hiromu Nakano on 9/5/24.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AppIntents
import IncomesPlaygrounds

struct OpenIncomesIntent: AppIntent {
    static var title = LocalizedStringResource("Open Incomes")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        try await IncomesIntent.performOpenIncomes()
    }
}

struct ShowItemListYearSectionIntent: AppIntent {
    static var title = LocalizedStringResource("Show Item List Year Section")

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        try await IncomesIntent.performShowItemListYearSection()
    }
}
