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
    enum ImportRoute: String, Identifiable {
        case camera

        var id: String {
            rawValue
        }
    }

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
    @State private var isApplyingInference = false
    @State private var errorMessage: String?
    @State private var selectedItem: PhotosPickerItem?
    @State private var scanner: ImageTextScanner = .init()

    var body: some View {
        @Bindable var scanner = scanner
        let isProcessing = isApplyingInference || scanner.isScanning

        Form {
            ItemFormRecognizedTextSection(
                recognizedText: $scanner.recognizedText,
                isRecognizedTextEmpty: scanner.recognizedText.isEmpty
            )
            if let processingState = processingState(
                isApplyingInference: isApplyingInference,
                isScanning: scanner.isScanning
            ) {
                ItemFormInputAssistProcessingSection(state: processingState)
            }
            ItemFormInputAssistImportSection(
                selectedItem: $selectedItem,
                isImportDisabled: isProcessing
            ) {
                importRoute = .camera
            }
        }
        .formStyle(.grouped)
        .contentMargins(.bottom, designMetrics.spacing.inline, for: .scrollContent)
        .navigationTitle("Text Capture")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ItemFormInputAssistToolbarContent(
                isProcessing: isProcessing,
                isDoneDisabled: isDoneDisabled(
                    recognizedText: scanner.recognizedText,
                    isProcessing: isProcessing
                ),
                cancel: {
                    dismiss()
                },
                done: {
                    Task {
                        await applyInferenceAndClose()
                    }
                }
            )
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
        isApplyingInference = true
        defer {
            isApplyingInference = false
        }
        do {
            let updatedInput = try await ItemFormInferenceApplier.apply(
                text: scanner.recognizedText,
                currentInput: model.formInputData,
                locale: locale,
                currentDate: Date(),
                logger: inferenceLogger
            )
            model.apply(updatedInput)
            dismiss()
        } catch {
            errorMessage = ErrorMessageOperations.message(from: error)
        }
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
