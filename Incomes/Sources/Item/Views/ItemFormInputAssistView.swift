//
//  ItemFormInputAssistView.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistView: View {
    @Binding private var date: Date
    @Binding private var content: String
    @Binding private var income: String
    @Binding private var outgo: String
    @Binding private var category: String
    @Binding private var priority: String

    @Environment(\.dismiss)
    private var dismiss

    @State private var text: String = .empty
    @State private var isProcessing = false
    @State private var errorMessage: String?

    @State private var isCameraPresented = false
    @State private var selectedItem: PhotosPickerItem?

    @StateObject private var scanner: ImageTextScanner = .init()

    init(
        date: Binding<Date>,
        content: Binding<String>,
        income: Binding<String>,
        outgo: Binding<String>,
        category: Binding<String>,
        priority: Binding<String>
    ) {
        _date = date
        _content = content
        _income = income
        _outgo = outgo
        _category = category
        _priority = priority
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
            let currentInput: ItemFormInput = .init(
                date: date,
                content: content,
                incomeText: income,
                outgoText: outgo,
                category: category,
                priorityText: priority
            )
            let updatedInput = try await ItemFormInferenceApplier.apply(
                text: text,
                currentInput: currentInput
            )
            date = updatedInput.date
            content = updatedInput.content
            income = updatedInput.incomeText
            outgo = updatedInput.outgoText
            category = updatedInput.category
            priority = updatedInput.priorityText
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
            category: .constant(.empty),
            priority: .constant("0")
        )
    }
}
