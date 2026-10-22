//
//  MonthlySummarySection.swift
//  Incomes
//
//  Created by Codex on 2026/03/04.
//

import MHPlatform
import SwiftData
import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummarySection: View {
    private struct GenerationRequest: Equatable {
        let date: Date
        let input: MonthlySummaryGenerationInput
        let revision: UUID
    }

    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(\.locale)
    private var locale

    @AppStorage(\.currencyCode, default: "")
    private var currencyCode

    @LedgerItemQuery private var currentItems: [Item]

    @LedgerItemQuery private var previousItems: [Item]

    @State private var generatedSummary: MonthlySummaryResult?
    @State private var completedRequest: GenerationRequest?
    @State private var activeRequestID: UUID?
    @State private var revision = UUID()
    @State private var isGenerating = false
    @State private var errorMessage: String?

    private let date: Date

    var body: some View {
        let request = generationRequest

        Color.clear
            .frame(width: .zero, height: .zero)
            .toolbar {
                MonthlySummaryToolbarContent(
                    isVisible: shouldDisplaySummaryControl,
                    generatedSummary: completedRequest == request ? generatedSummary : nil,
                    isGenerating: isGenerating,
                    errorMessage: errorMessage,
                    generateSummary: requestSummary
                )
            }
            .task(id: request) {
                await generateSummary(for: request)
            }
            .onDisappear {
                activeRequestID = nil
                isGenerating = false
            }
    }

    init(
        date: Date,
        currentItemsDescriptor: ItemFetchDescriptor? = nil,
        ledgerIdentifier: LedgerIdentifier = .default
    ) {
        self.date = date
        _currentItems = .init(
            currentItemsDescriptor ?? .items(.dateIsSameMonthAs(date), ledgerIdentifier: ledgerIdentifier)
        )
        _previousItems = .init(
            .items(
                .dateIsSameMonthAs(
                    MonthlySummaryOperations.previousMonthDate(from: date)
                ),
                ledgerIdentifier: ledgerIdentifier
            )
        )
    }
}

@available(iOS 26.0, *)
private extension MonthlySummarySection {
    private var generationRequest: GenerationRequest {
        .init(
            date: date,
            input: .init(
                currentItems: currentItems,
                previousItems: previousItems,
                currencyCode: currencyCode,
                localeIdentifier: locale.identifier
            ),
            revision: revision
        )
    }

    var shouldDisplaySummaryControl: Bool {
        guard !currentItems.isEmpty else {
            return false
        }
        return MonthlySummaryGenerator.canGenerate(locale: locale)
    }

    func requestSummary() {
        guard !isGenerating else {
            return
        }
        revision = UUID()
    }

    private func generateSummary(for request: GenerationRequest) async {
        guard shouldDisplaySummaryControl,
              completedRequest != request,
              !Task.isCancelled
        else {
            return
        }

        let requestID = UUID()
        activeRequestID = requestID
        generatedSummary = nil
        completedRequest = nil
        errorMessage = nil
        isGenerating = true
        defer {
            if activeRequestID == requestID {
                activeRequestID = nil
                isGenerating = false
            }
        }

        do {
            let summary = try await MonthlySummaryGenerator.generate(
                currentItems: currentItems,
                previousItems: previousItems,
                date: date,
                currencyCode: currencyCode,
                locale: locale,
                logger: IncomesLogging.logger(
                    logging: logging,
                    category: IncomesLogging.Category.inference,
                    source: #fileID
                )
            )
            guard !Task.isCancelled,
                  activeRequestID == requestID,
                  request == generationRequest
            else {
                return
            }
            generatedSummary = summary
            completedRequest = request
        } catch {
            guard !Task.isCancelled,
                  activeRequestID == requestID,
                  request == generationRequest
            else {
                return
            }
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }
}
