import Foundation

/// Request lifecycle for the experimental natural-language search.
///
/// Every submission gets a new revision. A completion is applied only while
/// its own submission is still pending, so a cancelled, edited, or superseded
/// request can never show results as if they belonged to the current request.
public struct NaturalLanguageSearchState: Equatable, Sendable {
    /// One submitted request with the date captured when it was submitted.
    public struct Submission: Hashable, Sendable {
        /// Monotonic revision distinguishing identical repeated requests.
        public let revision: Int
        /// Trimmed request text.
        public let request: String
        /// Current date captured for resolving relative months.
        public let currentDate: Date
    }

    /// Visible state of the latest request.
    public enum Phase: Equatable, Sendable {
        /// No request is pending or shown.
        case idle
        /// Conditions are being extracted for the submission.
        case interpreting(Submission)
        /// Validated conditions for the submission.
        case interpreted(Submission, ItemSearchConditions)
        /// The submission did not produce a query.
        case failed(Submission, NaturalLanguageSearchError)
    }

    /// Current phase.
    public private(set) var phase = Phase.idle

    /// Whether the currently interpreted conditions were confirmed for querying.
    public private(set) var hasConfirmedConditions = false

    private var latestRevision = 0

    /// Submission waiting for extraction, if any.
    public var pendingSubmission: Submission? {
        guard case .interpreting(let submission) = phase else {
            return nil
        }
        return submission
    }

    /// Validated conditions for the current request, if any.
    public var conditions: ItemSearchConditions? {
        guard case .interpreted(_, let conditions) = phase else {
            return nil
        }
        return conditions
    }

    /// Creates an idle state.
    public init() {
        // Starts idle.
    }

    /// Starts a new submission, replacing any pending or shown result.
    ///
    /// Requests that cannot run fail immediately without a pending submission.
    public mutating func submit(
        request: String,
        currentDate: Date
    ) {
        hasConfirmedConditions = false
        latestRevision += 1
        do {
            let validRequest = try NaturalLanguageSearchOperations.validatedRequest(request)
            phase = .interpreting(
                .init(
                    revision: latestRevision,
                    request: validRequest,
                    currentDate: currentDate
                )
            )
        } catch {
            phase = .failed(
                .init(
                    revision: latestRevision,
                    request: request.trimmingCharacters(in: .whitespacesAndNewlines),
                    currentDate: currentDate
                ),
                error as? NaturalLanguageSearchError ?? .generationFailed
            )
        }
    }

    /// Applies an extraction result when `submission` is still pending.
    ///
    /// - Returns: `true` when the result was applied.
    @discardableResult
    public mutating func complete(
        _ submission: Submission,
        with result: Result<ItemSearchConditions, NaturalLanguageSearchError>
    ) -> Bool {
        guard pendingSubmission == submission else {
            return false
        }
        switch result {
        case .success(let conditions):
            phase = .interpreted(submission, conditions)
        case .failure(let error):
            phase = .failed(submission, error)
        }
        return true
    }

    /// Allows querying only after the person has reviewed the interpreted conditions.
    public mutating func confirmConditions() {
        guard conditions != nil else {
            return
        }
        hasConfirmedConditions = true
    }

    /// Cancels a pending request or clears the shown result.
    public mutating func reset() {
        hasConfirmedConditions = false
        latestRevision += 1
        phase = .idle
    }

    /// Clears the current request when the input no longer matches it.
    public mutating func requestDidChange(_ request: String) {
        let submittedRequest: String
        switch phase {
        case .idle:
            return
        case .interpreting(let submission),
             .interpreted(let submission, _),
             .failed(let submission, _):
            submittedRequest = submission.request
        }
        guard request.trimmingCharacters(in: .whitespacesAndNewlines) != submittedRequest else {
            return
        }
        reset()
    }
}
