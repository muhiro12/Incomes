//
//  IncomesIntents.swift
//  Incomes
//
//  Created by Hiromu Nakano on 9/5/24.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AppIntents

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

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ReturnsValue<Date?> {
        try await IncomesIntents.performGetNextItemDate(date: date)
    }
}

struct GetNextItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Content")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetNextItemContent(date: date)
    }
}

struct GetNextItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Profit")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetNextItemProfit(date: date)
    }
}

struct ShowNextItemsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Next Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        try await IncomesIntents.performShowNextItems(date: date)
    }
}

// MARK: - Previous Item

struct GetPreviousItemDate: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Date")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ReturnsValue<Date?> {
        try await IncomesIntents.performGetPreviousItemDate(date: date)
    }
}

struct GetPreviousItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Content")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetPreviousItemContent(date: date)
    }
}

struct GetPreviousItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Profit")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        try await IncomesIntents.performGetPreviousItemProfit(date: date)
    }
}

struct ShowPreviousItemsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Previous Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        try await IncomesIntents.performShowPreviousItems(date: date)
    }
}

// MARK: - Item List

struct ShowItemsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        try await IncomesIntents.performShowItems(date: date)
    }
}

struct ShowChartsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Charts")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        try await IncomesIntents.performShowCharts(date: date)
    }
}
