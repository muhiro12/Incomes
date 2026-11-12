//
//  ItemFormInputAssistView.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import MHDesign
import MHPlatform
import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistView: View {
    enum ImportRoute: Hashable, Identifiable {
        case camera

        var id: Self {
            self
        }
    }

    var initialText: String?
    var onApply: (() -> Void)?

    @Environment(\.dismiss)
    private var dismiss
    @Environment(ItemFormModel.self)
    private var model
    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @Environment(\.locale)
    private var locale

    @State private var importRoute: ImportRoute?
    @State private var inferenceState = ItemFormInferenceState()
    @State private var errorMessage: String?
    @State private var selectedItem: PhotosPickerItem?
    @State private var scanner: ImageTextScanner = .init()
    @State private var hasLoadedInitialText = false

    var body: some View {
        @Bindable var scanner = scanner
        let currentProcessingState = processingState(
            isApplyingInference: inferenceState.pendingRequest != nil,
            isScanning: scanner.isScanning
        )
        let isProcessing = currentProcessingState != nil

        Form {
            ItemFormInputAssistImportSection(
                selectedItem: $selectedItem,
                isImportDisabled: isProcessing
            ) {
                importRoute = .camera
            }
            ItemFormRecognizedTextSection(
                recognizedText: $scanner.recognizedText,
                isRecognizedTextEmpty: scanner.recognizedText.isEmpty
            )
            if let currentProcessingState {
                ItemFormInputAssistProcessingSection(state: currentProcessingState)
            }
        }
        .formStyle(.grouped)
        .contentMargins(.bottom, designMetrics.spacing.inline, for: .scrollContent)
        .navigationTitle("Extract from Text")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ItemFormInputAssistToolbarContent(
                processingState: currentProcessingState,
                isDoneDisabled: isDoneDisabled(
                    recognizedText: scanner.recognizedText,
                    isProcessing: isProcessing
                ),
                cancel: {
                    inferenceState.cancel()
                    dismiss()
                },
                done: {
                    errorMessage = nil
                    inferenceState.submit(
                        text: scanner.recognizedText,
                        currentInput: model.formInputData
                    )
                }
            )
        }
        .task(id: inferenceState.pendingRequest) {
            await applyInferenceAndClose()
        }
        .onAppear {
            guard !hasLoadedInitialText else {
                return
            }
            hasLoadedInitialText = true
            scanner.recognizedText = initialText ?? model.inferenceText
        }
        .onDisappear {
            inferenceState.cancel()
        }
        .onChange(of: scanner.recognizedText) {
            model.inferenceText = scanner.recognizedText
            inferenceState.cancel()
        }
        .onChange(of: model.draftChangeKey) {
            inferenceState.cancel()
        }
        .sheet(item: $importRoute) { route in
            switch route {
            case .camera:
                CameraPicker { image in
                    Task {
                        await scanImage(image)
                    }
                }
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            guard newValue != nil else {
                return
            }
            Task {
                await scanReceipt()
            }
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
private extension ItemFormInputAssistView {
    func isDoneDisabled(
        recognizedText: String,
        isProcessing: Bool
    ) -> Bool {
        recognizedText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty || isProcessing
    }

    func processingState(
        isApplyingInference: Bool,
        isScanning: Bool
    ) -> ItemFormInputAssistProcessingState? {
        if isApplyingInference {
            return .applyingSuggestions
        }
        if isScanning {
            return .scanningImage
        }
        return nil
    }

    private func scanReceipt() async {
        guard let item = selectedItem else {
            return
        }
        defer {
            selectedItem = nil
        }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                return
            }
            await scanImage(image)
        } catch {
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    private func scanImage(_ image: UIImage) async {
        do {
            try await scanner.scan(image)
        } catch {
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    private func applyInferenceAndClose() async {
        guard !Task.isCancelled,
              let request = inferenceState.pendingRequest else {
            return
        }
        do {
            let update = try await ItemFormInferenceApplier.makeUpdate(
                text: request.text,
                locale: locale,
                currentDate: Date(),
                logger: inferenceLogger
            )
            try Task.checkCancellation()
            guard completeInference(request) else {
                return
            }
            model.applyInference(update)
            if let onApply {
                onApply()
            } else {
                dismiss()
            }
        } catch is CancellationError {
            if inferenceState.pendingRequest == request {
                inferenceState.cancel()
            }
        } catch {
            guard !Task.isCancelled,
                  completeInference(request) else {
                return
            }
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    private func completeInference(_ request: ItemFormInferenceState.Request) -> Bool {
        inferenceState.complete(
            request,
            currentText: scanner.recognizedText,
            currentInput: model.formInputData
        )
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistView {
    var inferenceLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.inference,
            source: #fileID
        )
    }
}

@available(iOS 26.0, *)
#Preview {
    NavigationStack {
        ItemFormInputAssistView()
            .environment(ItemFormModel())
            .environment(
                MainActor.assumeIsolated {
                    IncomesLogging.makeBootstrap()
                }
            )
    }
}
