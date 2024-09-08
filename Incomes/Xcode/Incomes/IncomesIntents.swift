//
//  IncomesIntents.swift
//  Incomes
//
//  Created by Hiromu Nakano on 9/5/24.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AppIntents
import IncomesPlaygrounds

// MARK: - Open

struct OpenIncomesIntent: AppIntent {
    static var title = LocalizedStringResource("Open Incomes")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        try await IncomesIntent.performOpenIncomes()
    }
}

// MARK: - Next Item

struct GetNextItemDate: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Date")

    func perform() async throws -> some IntentResult & ReturnsValue<Date?> {
        try await IncomesIntent.performGetNextItemDate()
    }
}

struct GetNextItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Content")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntent.performGetNextItemContent()
    }
}

struct GetNextItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Profit")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntent.performGetNextItemProfit()
    }
}

struct ShowNextItemIntent: AppIntent {
    static var title = LocalizedStringResource("Show Next Item")

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        try await IncomesIntent.performShowNextItem()
    }
}

// MARK: - Previous Item

struct GetPreviousItemDate: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Date")

    func perform() async throws -> some IntentResult & ReturnsValue<Date?> {
        try await IncomesIntent.performGetPreviousItemDate()
    }
}

struct GetPreviousItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Content")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntent.performGetPreviousItemContent()
    }
}

struct GetPreviousItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Profit")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntent.performGetPreviousItemProfit()
    }
}

struct ShowPreviousItemIntent: AppIntent {
    static var title = LocalizedStringResource("Show Previous Item")

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        try await IncomesIntent.performShowPreviousItem()
    }
}

// MARK: - Item List

struct ShowItemListIntent: AppIntent {
    static var title = LocalizedStringResource("Show Item List")

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        try await IncomesIntent.performShowItemList()
    }
}
