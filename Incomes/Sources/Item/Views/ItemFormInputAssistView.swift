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
    enum ImportRoute: String, Identifiable {
        case camera

        var id: String {
            rawValue
        }
    }

    private enum Constants {
        static let placeholderTopPadding: CGFloat = 10
        static let placeholderLeadingPadding: CGFloat = 8
        static let textEditorMinimumHeight: CGFloat = 220
        static let textEditorPadding: CGFloat = 8
        static let cardCornerRadius: CGFloat = 12
        static let cardBorderOpacity = 0.18
        static let cardBorderLineWidth: CGFloat = 1

        static let rowInsetTop: CGFloat = 8
        static let rowInsetLeading: CGFloat = 16
        static let rowInsetBottom: CGFloat = 12
        static let rowInsetTrailing: CGFloat = 16
    }

    @MainActor
    private final class Router: ObservableObject {
        @Published var importRoute: ImportRoute?

        func navigate(to route: ImportRoute) {
            importRoute = route
        }
    }

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

    @State private var selectedItem: PhotosPickerItem?

    @StateObject private var router: Router = .init()
    @StateObject private var scanner: ImageTextScanner = .init()

    var body: some View {
        Form {
            recognizedTextSection
            importSection
        }
        .formStyle(.grouped)
        .navigationTitle("Text Capture")
        .navigationBarTitleDisplayMode(.inline)
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
        .sheet(item: $router.importRoute) { route in
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
            Text(errorMessage ?? .empty)
        }
    }

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
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistView {
    var recognizedTextSection: some View {
        Section { // swiftlint:disable:this closure_body_length
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Paste or capture text to extract details.")
                        .foregroundStyle(.secondary)
                        .padding(.top, Constants.placeholderTopPadding)
                        .padding(.leading, Constants.placeholderLeadingPadding)
                }

                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: Constants.textEditorMinimumHeight)
                    .padding(Constants.textEditorPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.cardCornerRadius, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    .accessibilityLabel("Captured text")
            }
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cardCornerRadius, style: .continuous)
                    .stroke(
                        Color.secondary.opacity(Constants.cardBorderOpacity),
                        lineWidth: Constants.cardBorderLineWidth
                    )
            )
            .listRowInsets(
                .init(
                    top: Constants.rowInsetTop,
                    leading: Constants.rowInsetLeading,
                    bottom: Constants.rowInsetBottom,
                    trailing: Constants.rowInsetTrailing
                )
            )
        } header: {
            Text("Recognized Text")
        } footer: {
            Text("We will extract date, amounts, category, and priority from this text.")
        }
    }

    var importSection: some View {
        Section {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Photo Library", systemImage: "photo.on.rectangle")
            }
            .labelStyle(.titleAndIcon)

            Button {
                router.navigate(to: .camera)
            } label: {
                Label("Camera", systemImage: "camera")
            }
            .labelStyle(.titleAndIcon)
        } header: {
            Text("Import")
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
