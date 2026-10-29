import MHPlatform
import SwiftData
import SwiftUI

struct ItemTemplateInputView: View {
    @Environment(ItemFormModel.self)
    private var model
    @Environment(\.modelContext)
    private var context

    // The descriptor shorthand fixes .standard and bypasses scene-injected defaults.
    @AppStorage(MHPreferenceDescriptors().currencyCode.storageKey)
    private var currencyCode = ""

    @State private var review: ItemTemplateReview?
    @State private var errorMessage: String?
    @State private var confirmsCategory = false
    @State private var prompt = ""
    @State private var blankTemplate = ""

    private let minimumEditorHeight: CGFloat = 220

    let onApply: () -> Void

    var body: some View {
        Form {
            copySection
            inputSection
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
            }
            inferenceSection
            reviewSection
        }
        .navigationTitle("Read Template")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .task(id: currencyCode) {
            prepareTemplate()
        }
        .onChange(of: model.templateText) {
            invalidateReview()
        }
        .onChange(of: model.draftChangeKey) {
            invalidateReview()
        }
        .onChange(of: currencyCode) {
            invalidateReview()
        }
        .alert("New Category", isPresented: $confirmsCategory) {
            Button("Apply to Form") {
                applyTemplate()
            }
            Button("Cancel", role: .cancel) {
                // Keep the source and preview available for correction.
            }
        } message: {
            Text("Saving this item will create the category “\(review?.input.category ?? "")”.")
        }
    }
}

private extension ItemTemplateInputView {
    var copySection: some View {
        Section {
            if !blankTemplate.isEmpty {
                CopyTextContextMenuButton("Copy Template", text: blankTemplate)
                CopyTextContextMenuButton("Copy Prompt and Template", text: prompt)
                DisclosureGroup("Prompt and Template") {
                    Text(verbatim: prompt)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }
        } footer: {
            Text("Copy only what you want to share with an external tool. Nothing is sent automatically.")
        }
    }

    var inputSection: some View {
        @Bindable var model = model

        return Section {
            TextEditor(text: $model.templateText)
                .font(.body.monospaced())
                .frame(minHeight: minimumEditorHeight)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityLabel("Completed Template")
            Button("Review Template", action: readTemplate)
                .disabled(model.templateText.isEmpty)
        } header: {
            Text("Completed Template")
        } footer: {
            Text("Paste or enter one completed template. Invalid text stays here so you can correct it.")
        }
    }

    @ViewBuilder var inferenceSection: some View {
        if #available(iOS 26.0, *), !model.templateText.isEmpty {
            Section {
                NavigationLink {
                    ItemFormInputAssistView(initialText: model.templateText, onApply: onApply)
                } label: {
                    Label("Extract This Text", systemImage: "wand.and.stars")
                }
            } footer: {
                Text(
                    """
                    Uses Apple Intelligence to interpret the text again. \
                    Template values may be interpreted differently.
                    """
                )
            }
        }
    }

    @ViewBuilder var reviewSection: some View {
        if let review, isCurrent(review) {
            ItemTemplateReviewSection(input: review.input, currencyCode: currencyCode)
            Section {
                Button("Apply to Form", action: requestApply)
            } footer: {
                Text(
                    """
                    This replaces the current draft fields and turns off repetition. \
                    Review the form and choose Create to save.
                    """
                )
            }
        }
    }

    func prepareTemplate() {
        do {
            blankTemplate = try ItemTemplateOperations.blankTemplate(currencyCode: currencyCode)
            prompt = try ItemTemplateOperations.promptAndTemplate(currencyCode: currencyCode)
            errorMessage = nil
        } catch {
            blankTemplate = ""
            prompt = ""
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    func readTemplate() {
        invalidateReview()
        do {
            let input = try ItemTemplateOperations.read(
                model.templateText,
                ledgerIdentifier: model.ledgerIdentifier,
                currencyCode: currencyCode
            )
            review = .init(
                input: input,
                originalInput: model.formInputData,
                sourceText: model.templateText,
                currencyCode: currencyCode
            )
        } catch {
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    func requestApply() {
        guard let review, isCurrent(review) else {
            return
        }
        do {
            if try ItemTemplateOperations.requiresCategoryConfirmation(context: context, input: review.input) {
                confirmsCategory = true
            } else {
                applyTemplate()
            }
        } catch {
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    func applyTemplate() {
        guard let review, isCurrent(review) else {
            return
        }
        model.applyTemplate(review.input)
        onApply()
    }

    func isCurrent(_ review: ItemTemplateReview) -> Bool {
        review.isCurrent(
            input: model.formInputData,
            sourceText: model.templateText,
            currencyCode: currencyCode
        )
    }

    func invalidateReview() {
        review = nil
        confirmsCategory = false
        errorMessage = nil
    }
}
