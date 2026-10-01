import Foundation

/// Owns one inference request for an editable item form.
public struct ItemFormInferenceState: Equatable {
    /// Immutable input captured when assistance is requested.
    public struct Request: Equatable {
        /// Distinguishes requests even when their inputs are identical.
        public let id: UUID
        /// Captured source text for inference.
        public let text: String
        /// Draft that the generated values may update.
        public let input: ItemFormInput
    }

    /// Request whose completion may still update the draft.
    public private(set) var pendingRequest: Request?

    /// Creates a state with no pending request.
    public init() {
        // Starts idle.
    }

    /// Starts a new request, invalidating any previous request.
    public mutating func submit(text: String, currentInput: ItemFormInput) {
        pendingRequest = .init(id: UUID(), text: text, input: currentInput)
    }

    /// Invalidates pending work when assistance is cancelled or dismissed.
    public mutating func cancel() {
        pendingRequest = nil
    }

    /// Finishes only the pending request and checks that its inputs are current.
    ///
    /// A rejected old completion leaves a newer request pending. A completion
    /// for an edited draft or source text finishes without applying any result.
    /// - Returns: Whether the caller may apply the result or present its error.
    public mutating func complete(
        _ request: Request,
        currentText: String,
        currentInput: ItemFormInput
    ) -> Bool {
        guard pendingRequest == request else {
            return false
        }
        pendingRequest = nil
        return request.text == currentText && request.input == currentInput
    }
}
