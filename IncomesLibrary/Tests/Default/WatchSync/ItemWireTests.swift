import Foundation
@testable import IncomesLibrary
import Testing

struct ItemWireTests {
    enum SampleFailure: Error {
        case snapshotApply
    }

    @Test
    func itemsRequest_roundTrips_via_JSON() throws {
        let request = ItemsRequest(
            baseEpoch: 1_725_000_000,
            monthOffsets: ItemsRequest.recentMonthOffsets
        )
        let data = try ItemsRequest.requestData(for: request)
        let decoded = try ItemsRequest.decodeRequest(data)
        #expect(decoded.baseEpoch == request.baseEpoch)
        #expect(decoded.monthOffsets == request.monthOffsets)
    }

    @Test
    func itemsRequest_recentMonthOffsets_coverPreviousCurrentAndNextMonth() {
        #expect(ItemsRequest.recentMonthOffsets == [-1, 0, 1])
    }

    @Test
    func itemsRequest_recent_usesBaseDateAndRecentOffsets() {
        let baseDate = Date(timeIntervalSince1970: 1_725_000_000)
        let request = ItemsRequest.recent(baseDate: baseDate)

        #expect(request.baseEpoch == baseDate.timeIntervalSince1970)
        #expect(request.baseDate == baseDate)
        #expect(request.monthOffsets == ItemsRequest.recentMonthOffsets)
    }

    @Test
    func watchSyncReply_success_roundTrips_via_JSON() throws {
        let items = [
            ItemWire(dateEpoch: 1_725_000_000, content: "Salary", income: 3_000, outgo: 0, category: "Salary"),
            ItemWire(dateEpoch: 1_725_086_400, content: "Rent", income: 0, outgo: 1_200, category: "Housing")
        ]
        let reply = WatchSyncReply.success(items: items)
        let data = try WatchSyncReply.responseData(for: reply)
        let decoded = WatchSyncReply.decodeResponse(data)
        #expect(decoded.status == .success)
        #expect(decoded.items.count == 2)
        #expect(decoded.failure == nil)
        #expect(decoded.shouldApplySnapshot)
        #expect(decoded.items.first?.content == "Salary")
        #expect(decoded.items.last?.category == "Housing")
    }

    @Test
    func watchSyncReply_failure_roundTrips_via_JSON() throws {
        let reply = WatchSyncReply.failed(
            .init(
                phase: .transport,
                message: "Phone session is not reachable."
            )
        )
        let data = try WatchSyncReply.responseData(for: reply)
        let decoded = WatchSyncReply.decodeResponse(data)
        #expect(decoded.status == .failure)
        #expect(decoded.items.isEmpty)
        #expect(!decoded.shouldApplySnapshot)
        #expect(decoded.failure?.phase == .transport)
        #expect(decoded.failure?.message == "Phone session is not reachable.")
    }

    @Test
    func watchSyncReply_decodeResponse_returnsDecodeFailure_forMalformedPayload() {
        let decoded = WatchSyncReply.decodeResponse(Data("not-json".utf8))

        #expect(decoded.status == .failure)
        #expect(!decoded.shouldApplySnapshot)
        #expect(decoded.failure?.phase == .responseDecode)
    }

    @Test
    func watchSyncReply_responseEncodingFailureData_returnsResponseEncodeFailure() {
        let data = WatchSyncReply.responseEncodingFailureData(
            error: SampleFailure.snapshotApply
        )
        let decoded = WatchSyncReply.decodeResponse(data)

        #expect(decoded.status == .failure)
        #expect(!decoded.shouldApplySnapshot)
        #expect(decoded.failure?.phase == .responseEncode)
    }

    @Test
    func watchSyncReply_encodedResponseData_reportsEncodingFailureAndReturnsFallback() {
        let reply = WatchSyncReply.success(
            items: [
                .init(
                    dateEpoch: .nan,
                    content: "Invalid",
                    income: 0,
                    outgo: 0,
                    category: "Invalid"
                )
            ]
        )
        var capturedError: (any Error)?
        let data = WatchSyncReply.encodedResponseData(for: reply) { error in
            capturedError = error
        }
        let decoded = WatchSyncReply.decodeResponse(data)

        #expect(capturedError != nil)
        #expect(decoded.status == .failure)
        #expect(decoded.failure?.phase == .responseEncode)
    }

    @Test
    func watchSyncReply_failureAndEmptySuccess_remain_distinguishable_for_snapshot_apply() {
        let unreachableReply = WatchSyncReply.failed(
            phase: .sessionUnreachable,
            message: "Phone session is not reachable."
        )
        let emptySuccessReply = WatchSyncReply.success(items: [])

        #expect(!unreachableReply.shouldApplySnapshot)
        #expect(!unreachableReply.isEmptySuccess)
        #expect(emptySuccessReply.shouldApplySnapshot)
        #expect(emptySuccessReply.isEmptySuccess)
    }

    @Test
    func watchSyncReply_failedWithError_preservesSnapshotApplyPhase() {
        let reply = WatchSyncReply.failed(
            phase: .snapshotApply,
            error: SampleFailure.snapshotApply
        )

        #expect(reply.status == .failure)
        #expect(reply.failure?.phase == .snapshotApply)
        #expect(!reply.shouldApplySnapshot)
    }

    @Test
    func watchSyncFailurePhase_connectivityFailures_are_classified() {
        #expect(WatchSyncFailurePhase.sessionUnreachable.isConnectivityFailure)
        #expect(WatchSyncFailurePhase.transport.isConnectivityFailure)
        #expect(!WatchSyncFailurePhase.requestDecode.isConnectivityFailure)
        #expect(!WatchSyncFailurePhase.missingContext.isConnectivityFailure)
        #expect(!WatchSyncFailurePhase.itemFetch.isConnectivityFailure)
        #expect(!WatchSyncFailurePhase.responseEncode.isConnectivityFailure)
        #expect(!WatchSyncFailurePhase.requestEncode.isConnectivityFailure)
        #expect(!WatchSyncFailurePhase.responseDecode.isConnectivityFailure)
        #expect(!WatchSyncFailurePhase.snapshotApply.isConnectivityFailure)
    }
}
