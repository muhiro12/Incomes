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
        try await IncomesIntents.performOpenIncomes()
    }
}

// MARK: - Next Item

struct GetNextItemDate: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Date")

    func perform() async throws -> some IntentResult & ReturnsValue<Date?> {
        try await IncomesIntents.performGetNextItemDate()
    }
}

struct GetNextItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Content")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetNextItemContent()
    }
}

struct GetNextItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Profit")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetNextItemProfit()
    }
}

struct ShowNextItemIntent: AppIntent {
    static var title = LocalizedStringResource("Show Next Item")

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        try await IncomesIntents.performShowNextItem()
    }
}

// MARK: - Previous Item

struct GetPreviousItemDate: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Date")

    func perform() async throws -> some IntentResult & ReturnsValue<Date?> {
        try await IncomesIntents.performGetPreviousItemDate()
    }
}

struct GetPreviousItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Content")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetPreviousItemContent()
    }
}

struct GetPreviousItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Profit")

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetPreviousItemProfit()
    }
}

struct ShowPreviousItemIntent: AppIntent {
    static var title = LocalizedStringResource("Show Previous Item")

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        try await IncomesIntents.performShowPreviousItem()
    }
}

// MARK: - Item List

struct ShowItemListIntent: AppIntent {
    static var title = LocalizedStringResource("Show Item List")

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        try await IncomesIntents.performShowItemList()
    }
}
