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
    @Environment(\.locale)
    private var locale

    @AppStorage(\.currencyCode, default: "")
    private var currencyCode

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

    var body: some View {
        Color.clear
            .frame(width: .zero, height: .zero)
            .toolbar {
                MonthlySummaryToolbarContent(
                    isVisible: shouldDisplaySummaryControl,
                    generatedSummary: generatedSummary,
                    isGenerating: isGenerating,
                    isPopoverPresented: $isPopoverPresented,
                    generateInitialSummary: generateInitialSummaryFromToolbar,
                    generateSummary: generateSummaryFromPopover
                )
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

    init(
        date: Date,
        currentItemsDescriptor: FetchDescriptor<Item>? = nil
    ) {
        self.date = date
        _currentItems = .init(currentItemsDescriptor ?? .items(.dateIsSameMonthAs(date)))
        _previousItems = .init(
            .items(
                .dateIsSameMonthAs(
                    MonthlySummaryOperations.previousMonthDate(from: date)
                )
            )
        )
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

    func generateInitialSummaryFromToolbar() {
        guard generatedSummary == nil,
              !isGenerating else {
            return
        }
        Task {
            await generateSummary(
                presentsErrors: true,
                forceRegeneration: false
            )
        }
    }

    func generateSummaryFromPopover() {
        Task {
            await generateSummary(
                presentsErrors: true,
                forceRegeneration: true
            )
        }
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
                currentItems: currentItems,
                previousItems: previousItems,
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
