//
//  ItemFormInputAssistView.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import PhotosUI
import SpeechWrapper
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistView: View {
    @Binding private var date: Date
    @Binding private var content: String
    @Binding private var income: String
    @Binding private var outgo: String
    @Binding private var category: String

    @Environment(\.dismiss)
    private var dismiss

    @State private var text: String = .empty
    @State private var isProcessing = false
    @State private var errorMessage: String?

    @State private var isCameraPresented = false
    @State private var selectedItem: PhotosPickerItem?

    @StateObject private var scanner: ImageTextScanner = .init()
    private let speechClient = SpeechClient(settings: .init(useLegacy: true))
    @State private var isRecording = false

    init(
        date: Binding<Date>,
        content: Binding<String>,
        income: Binding<String>,
        outgo: Binding<String>,
        category: Binding<String>
    ) {
        _date = date
        _content = content
        _income = income
        _outgo = outgo
        _category = category
    }

    var body: some View {
        VStack(spacing: 16) {
            TextEditor(text: $text)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 220)
                .accessibilityLabel("Captured text")

            HStack(spacing: 24) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Library", systemImage: "photo")
                }

                Button {
                    isCameraPresented = true
                } label: {
                    Label("Camera", systemImage: "camera")
                }

                if isRecording {
                    Button {
                        Task {
                            await stopRecording()
                        }
                    } label: {
                        Label("Stop", systemImage: "stop.circle.fill")
                    }
                } else {
                    Button {
                        Task {
                            await startRecording()
                        }
                    } label: {
                        Label("Microphone", systemImage: "mic")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Capture Text")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await applyInferenceAndClose()
                    }
                } label: {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("Done")
                    }
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraPicker { image in
                Task {
                    await scanImage(image)
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
            Text(errorMessage ?? .empty)
        }
    }

    // MARK: - Actions

    private func startRecording() async {
        isProcessing = true
        defer {
            isProcessing = false
        }
        do {
            let stream = try await speechClient.stream()
            isRecording = true
            for await latest in stream {
                text = latest
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stopRecording() async {
        isProcessing = true
        defer {
            isProcessing = false
        }
        await speechClient.stop()
        isRecording = false
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
            errorMessage = error.localizedDescription
        }
    }

    private func scanImage(_ image: UIImage) async {
        isProcessing = true
        defer {
            isProcessing = false
        }
        do {
            try await scanner.scan(image)
            text = scanner.recognizedText
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyInferenceAndClose() async {
        isProcessing = true
        defer {
            isProcessing = false
        }
        do {
            let inference = try await ItemService.inferForm(text: text)
            let update = ItemFormInferenceMapper.map(
                dateString: inference.date,
                content: inference.content,
                income: inference.income,
                outgo: inference.outgo,
                category: inference.category
            )
            if let newDate = update.date {
                date = newDate
            }
            content = update.content
            income = update.incomeText
            outgo = update.outgoText
            category = update.category
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    NavigationStack {
        ItemFormInputAssistView(
            date: .constant(.now),
            content: .constant(.empty),
            income: .constant(.empty),
            outgo: .constant(.empty),
            category: .constant(.empty)
        )
    }
}
