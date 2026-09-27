import Foundation
@testable import IncomesLibrary
import Testing

struct NaturalLanguageSearchStateTests {
    private let currentDate = isoDate("2026-09-15T03:00:00Z")
    private let rentConditions = ItemSearchConditions(content: "rent")
    private let parkingConditions = ItemSearchConditions(content: "parking")

    @Test("Only reviewed conditions can be queried and editing clears confirmation")
    func confirmation_is_bound_to_current_conditions() throws {
        var state = NaturalLanguageSearchState()
        state.confirmConditions()
        #expect(!state.hasConfirmedConditions)
        state.submit(request: "rent", currentDate: currentDate)
        state.confirmConditions()
        #expect(!state.hasConfirmedConditions)
        state.complete(try #require(state.pendingSubmission), with: .success(rentConditions))
        #expect(!state.hasConfirmedConditions)
        state.confirmConditions()
        #expect(state.hasConfirmedConditions)
        state.requestDidChange("parking")
        #expect(!state.hasConfirmedConditions)
        #expect(state.conditions == nil)
    }

    @Test("A pending submission receives its own conditions")
    func pending_submission_completes() throws {
        var state = NaturalLanguageSearchState()
        state.submit(request: " rent ", currentDate: currentDate)
        let submission = try #require(state.pendingSubmission)

        #expect(submission.request == "rent")
        let isApplied = state.complete(submission, with: .success(rentConditions))
        #expect(isApplied)
        #expect(state.conditions == rentConditions)
        #expect(state.pendingSubmission == nil)
    }

    @Test("A superseded completion cannot replace the newer request")
    func superseded_completion_is_ignored() throws {
        var state = NaturalLanguageSearchState()
        state.submit(request: "rent", currentDate: currentDate)
        let oldSubmission = try #require(state.pendingSubmission)
        state.submit(request: "parking", currentDate: currentDate)
        let newSubmission = try #require(state.pendingSubmission)

        let isOldApplied = state.complete(oldSubmission, with: .success(rentConditions))
        #expect(isOldApplied == false)
        #expect(state.conditions == nil)
        let isNewApplied = state.complete(newSubmission, with: .success(parkingConditions))
        #expect(isNewApplied)
        #expect(state.conditions == parkingConditions)
        let isLateOldApplied = state.complete(oldSubmission, with: .success(rentConditions))
        #expect(isLateOldApplied == false)
        #expect(state.conditions == parkingConditions)
    }

    @Test("Repeating the same text still creates a distinct submission")
    func identical_resubmission_is_distinct() throws {
        var state = NaturalLanguageSearchState()
        state.submit(request: "rent", currentDate: currentDate)
        let firstSubmission = try #require(state.pendingSubmission)
        state.submit(request: "rent", currentDate: currentDate)
        let secondSubmission = try #require(state.pendingSubmission)

        #expect(firstSubmission != secondSubmission)
        let isFirstApplied = state.complete(firstSubmission, with: .success(rentConditions))
        #expect(isFirstApplied == false)
        #expect(state.pendingSubmission == secondSubmission)
    }

    @Test("Cancelling a pending request drops its later completion")
    func cancelled_completion_is_ignored() throws {
        var state = NaturalLanguageSearchState()
        state.submit(request: "rent", currentDate: currentDate)
        let submission = try #require(state.pendingSubmission)

        state.reset()

        let isApplied = state.complete(submission, with: .success(rentConditions))
        #expect(isApplied == false)
        #expect(state.phase == .idle)
    }

    @Test("A failure replaces previously shown results")
    func failure_clears_previous_results() throws {
        var state = NaturalLanguageSearchState()
        state.submit(request: "rent", currentDate: currentDate)
        state.complete(try #require(state.pendingSubmission), with: .success(rentConditions))
        state.submit(request: "coffee", currentDate: currentDate)

        #expect(state.conditions == nil)

        let submission = try #require(state.pendingSubmission)
        state.complete(submission, with: .failure(.unsupportedTerms(["subscriptions"])))

        #expect(state.conditions == nil)
        #expect(state.phase == .failed(submission, .unsupportedTerms(["subscriptions"])))
    }

    @Test("Editing the request clears results, but unchanged text keeps them")
    func editing_request_clears_results() throws {
        var state = NaturalLanguageSearchState()
        state.submit(request: "rent", currentDate: currentDate)
        state.complete(try #require(state.pendingSubmission), with: .success(rentConditions))

        state.requestDidChange("rent ")
        #expect(state.conditions == rentConditions)

        state.requestDidChange("rent next")
        #expect(state.phase == .idle)
    }

    @Test("Editing during interpretation drops the pending completion")
    func editing_pending_request_drops_completion() throws {
        var state = NaturalLanguageSearchState()
        state.submit(request: "rent", currentDate: currentDate)
        let submission = try #require(state.pendingSubmission)

        state.requestDidChange("rents")

        let isApplied = state.complete(submission, with: .success(rentConditions))
        #expect(isApplied == false)
        #expect(state.conditions == nil)
    }

    @Test("Requests that cannot run fail without a pending generation")
    func invalid_requests_fail_immediately() {
        var state = NaturalLanguageSearchState()

        state.submit(request: "  ", currentDate: currentDate)
        #expect(state.pendingSubmission == nil)
        guard case .failed(_, .emptyRequest) = state.phase else {
            Issue.record("Expected an empty request failure")
            return
        }

        state.submit(request: "delete rent", currentDate: currentDate)
        #expect(state.pendingSubmission == nil)
        guard case .failed(_, .unsupportedAction) = state.phase else {
            Issue.record("Expected an unsupported action failure")
            return
        }
    }
}
