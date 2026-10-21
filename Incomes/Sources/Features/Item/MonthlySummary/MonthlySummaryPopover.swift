import MHDesign
import MHPlatform
import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryPopover: View {
    private enum Constants {
        static let accessibilityPopoverIdealWidth: CGFloat = 360
        static let accessibilityPopoverMaximumWidth: CGFloat = 420
        static let popoverIdealWidth: CGFloat = 320
        static let popoverMaximumWidth: CGFloat = 360
        static let popoverMinimumWidth: CGFloat = 280
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(\.locale)
    private var locale
    @AppStorage(\.currencyCode, default: "")
    private var currencyCode

    @State private var generatedSummary: MonthlySummaryResult?
    @State private var generationRequestID: UUID?
    @State private var isGenerating = false
    @State private var errorMessage: String?

    let date: Date
    let currentItems: [Item]
    let previousItems: [Item]

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: designMetrics.spacing.inline) {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                MonthlySummaryHeader(spacing: designMetrics.spacing.inline)
                MonthlySummaryContent(
                    generatedSummary: generatedSummary,
                    isGenerating: isGenerating,
                    spacing: designMetrics.spacing.inline,
                    generateSummary: requestSummary
                )

                generationNotice

                if generatedSummary != nil {
                    MonthlySummaryGenerateButton(
                        title: "Regenerate Summary",
                        isDisabled: isGenerating,
                        action: requestSummary
                    )
                }
            }
            .frame(
                minWidth: Constants.popoverMinimumWidth,
                idealWidth: popoverIdealWidth,
                maxWidth: popoverMaximumWidth,
                alignment: .leading
            )
            .padding()
        }
        .task(id: generationRequestID) {
            guard let generationRequestID else {
                return
            }
            await generateSummary(requestID: generationRequestID)
        }
        .onChange(of: generationInput) {
            generationRequestID = nil
            generatedSummary = nil
            errorMessage = nil
            isGenerating = false
        }
        .onDisappear {
            generationRequestID = nil
            isGenerating = false
        }
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryPopover {
    var generationNotice: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text("Uses the on-device model behind Apple Intelligence. Check generated text against your items.")
            if let generatedSummary, !generatedSummary.isModelGenerated {
                Text("Text generation could not be completed. Showing calculated totals instead.")
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }

    var popoverIdealWidth: CGFloat {
        if dynamicTypeSize.isAccessibilitySize {
            return Constants.accessibilityPopoverIdealWidth
        }
        return Constants.popoverIdealWidth
    }

    var popoverMaximumWidth: CGFloat {
        if dynamicTypeSize.isAccessibilitySize {
            return Constants.accessibilityPopoverMaximumWidth
        }
        return Constants.popoverMaximumWidth
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryPopover {
    var generationInput: MonthlySummaryGenerationInput {
        .init(
            currentItems: currentItems,
            previousItems: previousItems,
            currencyCode: currencyCode,
            localeIdentifier: locale.identifier
        )
    }

    func requestSummary() {
        guard !isGenerating else {
            return
        }
        generationRequestID = UUID()
    }

    func generateSummary(requestID: UUID) async {
        let expectedInput = generationInput
        isGenerating = true
        defer {
            if generationRequestID == requestID {
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
            guard !Task.isCancelled, generationRequestID == requestID, expectedInput == generationInput else {
                return
            }
            generatedSummary = summary
        } catch {
            guard !Task.isCancelled, generationRequestID == requestID else {
                return
            }
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }
}
