//
//  MonthlySummarySection.swift
//  Incomes
//
//  Created by Codex on 2026/03/04.
//

import MHDesign
import MHPlatform
import SwiftData
import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummarySection: View {
    private enum Constants {
        static let popoverIdealWidth: CGFloat = 320
        static let popoverMaximumWidth: CGFloat = 360
        static let popoverMinimumWidth: CGFloat = 280
    }

    @Environment(\.modelContext)
    private var context

    @Environment(\.locale)
    private var locale

    @AppStorage(\.currencyCode, default: "")
    private var currencyCode
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @AppStorage(\.isDebugOn)
    private var isDebugOn

    @Query private var currentItems: [Item]

    @Query private var previousItems: [Item]

    @State private var generatedSummary: String?
    @State private var isGenerating = false
    @State private var isPopoverPresented = false
    @State private var errorMessage: String?
    @State private var activeRequestID: UUID?

    private let date: Date

    init(date: Date) { // swiftlint:disable:this type_contents_order
        self.date = date
        _currentItems = .init(.items(.dateIsSameMonthAs(date)))
        _previousItems = .init(
            .items(
                .dateIsSameMonthAs(
                    MonthlySummaryOperations.previousMonthDate(from: date)
                )
            )
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
                Text(errorMessage ?? "")
            }
    }
}

@available(iOS 26.0, *)
private extension MonthlySummarySection {
    var shouldDisplaySummaryControl: Bool {
        guard isDebugOn else {
            return false
        }
        guard !currentItems.isEmpty else {
            return false
        }
        return MonthlySummaryGenerator.canGenerate(locale: locale)
    }

    private var generationInput: MonthlySummaryGenerationInput {
        .init(
            currentItems: currentItems,
            previousItems: previousItems,
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

    @ViewBuilder private var summaryPopover: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text("Monthly Summary")
                .font(.headline)

            summaryContent

            Text("Generated on device. Your financial data stays on this device.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if generatedSummary != nil {
                regenerateSummaryButton
            }
        }
        .frame(
            minWidth: Constants.popoverMinimumWidth,
            idealWidth: Constants.popoverIdealWidth,
            maxWidth: Constants.popoverMaximumWidth,
            alignment: .leading
        )
        .padding()
    }

    @ViewBuilder private var summaryContent: some View {
        if let generatedSummary {
            Text(generatedSummary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        } else if isGenerating {
            HStack(spacing: designMetrics.spacing.inline) {
                ProgressView()
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            generateSummaryButton(title: "Generate Summary")
        }
    }

    private var regenerateSummaryButton: some View {
        generateSummaryButton(title: "Regenerate Summary")
            .disabled(isGenerating)
    }

    private func generateSummaryButton(title: LocalizedStringKey) -> some View {
        Button(title) {
            Task {
                await generateSummary(
                    presentsErrors: true,
                    forceRegeneration: true
                )
            }
        }
        .buttonStyle(.glassProminent)
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
                context: context,
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
                errorMessage = ErrorMessageOperations.message(from: error)
            }
        }
    }

    func clearGeneratedSummary() {
        generatedSummary = nil
        errorMessage = nil
    }
}
