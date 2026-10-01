import Foundation
import IncomesLibrary
import Testing

struct ItemFormInferenceStateTests {
    private let sourceText = "Synthetic receipt: coffee 500"
    private let originalInput = ItemFormInput(
        date: Date(timeIntervalSince1970: 1_000),
        content: "Manual draft",
        incomeText: "",
        outgoText: "100",
        category: "Manual category",
        priorityText: "2"
    )
    private let generatedInput = ItemFormInput(
        date: Date(timeIntervalSince1970: 2_000),
        content: "Coffee",
        incomeText: "",
        outgoText: "500",
        category: "Food",
        priorityText: "2"
    )

    @Test("An unchanged draft accepts its own result only once")
    func current_request_completes_once() throws {
        var state = ItemFormInferenceState()
        var draft = originalInput
        state.submit(text: sourceText, currentInput: draft)
        let request = try #require(state.pendingRequest)

        #expect(request.text == sourceText)
        #expect(request.input == originalInput)
        #expect(draft == originalInput)
        if state.complete(request, currentText: sourceText, currentInput: draft) {
            draft = generatedInput
        }

        #expect(draft == generatedInput)
        #expect(state.pendingRequest == nil)
        let isRepeatedCompletionAccepted = state.complete(
            request, currentText: sourceText, currentInput: originalInput
        )
        #expect(!isRepeatedCompletionAccepted)
    }

    @Test("Cancellation or dismissal rejects a delayed success and error")
    func cancelled_request_preserves_manual_draft() throws {
        var state = ItemFormInferenceState()
        var draft = originalInput
        state.submit(text: sourceText, currentInput: draft)
        let request = try #require(state.pendingRequest)

        state.cancel()
        if state.complete(request, currentText: sourceText, currentInput: draft) {
            draft = generatedInput
        }

        #expect(draft == originalInput)
        let isLateErrorAccepted = state.complete(request, currentText: sourceText, currentInput: draft)
        #expect(!isLateErrorAccepted)
        #expect(state.pendingRequest == nil)
    }

    @Test("Identical new requests reject older completions without clearing new work")
    func superseded_request_leaves_new_request_pending() throws {
        var state = ItemFormInferenceState()
        state.submit(text: sourceText, currentInput: originalInput)
        let oldRequest = try #require(state.pendingRequest)
        state.submit(text: sourceText, currentInput: originalInput)
        let newRequest = try #require(state.pendingRequest)

        #expect(oldRequest.id != newRequest.id)
        let isOldCompletionAccepted = state.complete(oldRequest, currentText: sourceText, currentInput: originalInput)
        #expect(!isOldCompletionAccepted)
        #expect(state.pendingRequest == newRequest)
        let isNewCompletionAccepted = state.complete(newRequest, currentText: sourceText, currentInput: originalInput)
        #expect(isNewCompletionAccepted)
        let isLateOldCompletionAccepted = state.complete(
            oldRequest,
            currentText: sourceText,
            currentInput: originalInput
        )
        #expect(!isLateOldCompletionAccepted)
    }

    @Test("Editing any draft field rejects generated values", arguments: 0..<6)
    func edited_draft_is_preserved(field: Int) throws {
        var state = ItemFormInferenceState()
        state.submit(text: sourceText, currentInput: originalInput)
        let request = try #require(state.pendingRequest)
        let editedInput = ItemFormInput(
            date: field == 0 ? Date(timeIntervalSince1970: 3_000) : originalInput.date,
            content: field == 1 ? "User correction" : originalInput.content,
            incomeText: field == 2 ? "200" : originalInput.incomeText,
            outgoText: field == 3 ? "300" : originalInput.outgoText,
            category: field == 4 ? "User category" : originalInput.category,
            priorityText: field == 5 ? "5" : originalInput.priorityText
        )
        var draft = editedInput

        if state.complete(request, currentText: sourceText, currentInput: draft) {
            draft = generatedInput
        }

        #expect(draft == editedInput)
        #expect(state.pendingRequest == nil)
    }

    @Test("Editing captured text rejects the old extraction")
    func edited_source_text_rejects_completion() throws {
        var state = ItemFormInferenceState()
        state.submit(text: sourceText, currentInput: originalInput)
        let request = try #require(state.pendingRequest)

        let isCompletionAccepted = state.complete(
            request,
            currentText: "Corrected receipt",
            currentInput: originalInput
        )
        #expect(!isCompletionAccepted)
        #expect(state.pendingRequest == nil)
    }

    @Test("Cancelling an edit rejects its result even if the draft is restored")
    func invalidated_request_cannot_be_revived() throws {
        var state = ItemFormInferenceState()
        state.submit(text: sourceText, currentInput: originalInput)
        let request = try #require(state.pendingRequest)

        state.cancel()

        let isCompletionAccepted = state.complete(request, currentText: sourceText, currentInput: originalInput)
        #expect(!isCompletionAccepted)
    }

    @Test("A request from a destroyed sheet cannot complete in a reopened sheet")
    func reopened_assistance_rejects_previous_request() throws {
        var oldState = ItemFormInferenceState()
        oldState.submit(text: sourceText, currentInput: originalInput)
        let oldRequest = try #require(oldState.pendingRequest)
        oldState.cancel()
        var newState = ItemFormInferenceState()
        newState.submit(text: sourceText, currentInput: originalInput)
        let newRequest = try #require(newState.pendingRequest)

        let isOldCompletionAccepted = newState.complete(
            oldRequest,
            currentText: sourceText,
            currentInput: originalInput
        )
        #expect(!isOldCompletionAccepted)
        #expect(newState.pendingRequest == newRequest)
    }

    @Test("Finishing a failed request allows a fresh retry without changing the draft")
    func failure_allows_retry() throws {
        var state = ItemFormInferenceState()
        state.submit(text: sourceText, currentInput: originalInput)
        let failedRequest = try #require(state.pendingRequest)

        let isErrorAccepted = state.complete(failedRequest, currentText: sourceText, currentInput: originalInput)
        #expect(isErrorAccepted)
        #expect(state.pendingRequest == nil)
        state.submit(text: sourceText, currentInput: originalInput)
        let retry = try #require(state.pendingRequest)

        #expect(retry.id != failedRequest.id)
        #expect(retry.input == originalInput)
        let isLateErrorAccepted = state.complete(failedRequest, currentText: sourceText, currentInput: originalInput)
        #expect(!isLateErrorAccepted)
        #expect(state.pendingRequest == retry)
    }
}
