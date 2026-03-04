//
//  MonthlySummarySection.swift
//  Incomes
//
//  Created by Codex on 2026/03/04.
//

import FoundationModels
import SwiftData
import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummarySection: View {
    private struct SummarySourceSnapshot: Equatable {
        let id: String
        let date: Date
        let content: String
        let income: Decimal
        let outgo: Decimal
        let category: String
    }

    private struct SummaryGenerationInput: Equatable {
        let snapshots: [SummarySourceSnapshot]
        let currencyCode: String
        let localeIdentifier: String
    }

    @Environment(\.modelContext)
    private var context

    @Environment(\.locale)
    private var locale

    @AppStorage(.currencyCode)
    private var currencyCode

    @Query
    private var currentItems: [Item]

    @Query
    private var previousItems: [Item]

    @State private var languageModel = SystemLanguageModel.default
    @State private var generatedSummary: String?
    @State private var isGenerating = false
    @State private var isPopoverPresented = false
    @State private var errorMessage: String?
    @State private var activeRequestID: UUID?

    private let date: Date

    init(date: Date) {
        self.date = date
        _currentItems = .init(.items(.dateIsSameMonthAs(date)))
        _previousItems = .init(
            .items(.dateIsSameMonthAs(Self.previousMonthDate(from: date)))
        )
    }

    var body: some View {
        Color.clear
            .frame(width: .zero, height: .zero)
            .toolbar {
                if shouldDisplaySummaryControl {
                    ToolbarItem(placement: .topBarTrailing) {
                        summaryToolbarButton
                    }
                }
            }
            .task(id: generationInput) {
                await generateSummary(
                    presentsErrors: false,
                    forceRegeneration: false
                )
            }
            .onChange(of: generationInput) { _, _ in
                clearGeneratedSummary()
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: {
                        errorMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? .empty)
            }
    }
}

@available(iOS 26.0, *)
private extension MonthlySummarySection {
    var shouldDisplaySummaryControl: Bool {
        guard !currentItems.isEmpty else {
            return false
        }
        guard languageModel.availability == .available else {
            return false
        }
        return languageModel.supportsLocale(locale)
    }

    private var generationInput: SummaryGenerationInput {
        .init(
            snapshots: summarySourceSnapshots,
            currencyCode: currencyCode,
            localeIdentifier: locale.identifier
        )
    }

    private var summaryToolbarButton: some View {
        Button {
            isPopoverPresented = true
            if generatedSummary == nil,
               !isGenerating {
                Task {
                    await generateSummary(
                        presentsErrors: true,
                        forceRegeneration: false
                    )
                }
            }
        } label: {
            if isGenerating,
               generatedSummary == nil {
                ProgressView()
            } else {
                Image(systemName: "sparkles")
            }
        }
        .accessibilityLabel(Text("Monthly Summary"))
        .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
            summaryPopover
                .presentationCompactAdaptation(.popover)
        }
    }

    @ViewBuilder
    private var summaryPopover: some View {
        VStack(alignment: .leading, spacing: .space(.s)) {
            Text("Monthly Summary")
                .font(.headline)

            if let generatedSummary {
                Text(generatedSummary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            } else if isGenerating {
                HStack(spacing: .space(.s)) {
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Button("Generate Summary") {
                    Task {
                        await generateSummary(
                            presentsErrors: true,
                            forceRegeneration: true
                        )
                    }
                }
                .buttonStyle(.bordered)
            }

            Text("Generated on device. Your financial data stays on this device.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if generatedSummary != nil {
                Button("Regenerate Summary") {
                    Task {
                        await generateSummary(
                            presentsErrors: true,
                            forceRegeneration: true
                        )
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isGenerating)
            }
        }
        .frame(minWidth: 280, idealWidth: 320, maxWidth: 360, alignment: .leading)
        .padding()
    }

    private var summarySourceSnapshots: [SummarySourceSnapshot] {
        currentItems.map(snapshot(for:)) + previousItems.map(snapshot(for:))
    }

    @MainActor
    func generateSummary(
        presentsErrors: Bool,
        forceRegeneration: Bool
    ) async {
        guard shouldDisplaySummaryControl else {
            return
        }
        guard forceRegeneration || generatedSummary == nil else {
            return
        }

        let requestID = UUID()
        let expectedGenerationInput = generationInput
        activeRequestID = requestID
        isGenerating = true
        defer {
            if activeRequestID == requestID {
                activeRequestID = nil
                isGenerating = false
            }
        }

        do {
            let summary = try await MonthlySummaryGenerator.generate(
                modelContainer: context.container,
                date: date,
                currencyCode: currencyCode,
                locale: locale
            )
            guard !Task.isCancelled,
                  activeRequestID == requestID,
                  expectedGenerationInput == generationInput else {
                return
            }
            generatedSummary = summary
        } catch {
            guard !Task.isCancelled,
                  activeRequestID == requestID else {
                return
            }
            if presentsErrors {
                errorMessage = resolvedErrorMessage(from: error)
            }
        }
    }

    private func snapshot(for item: Item) -> SummarySourceSnapshot {
        .init(
            id: String(describing: item.persistentModelID),
            date: item.utcDate,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: item.category?.displayName ?? "Others"
        )
    }

    func clearGeneratedSummary() {
        generatedSummary = nil
        errorMessage = nil
    }

    func resolvedErrorMessage(from error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return error.localizedDescription
    }

    static func previousMonthDate(from date: Date) -> Date {
        Calendar.utc.date(byAdding: .month, value: -1, to: date) ?? date
    }
}
