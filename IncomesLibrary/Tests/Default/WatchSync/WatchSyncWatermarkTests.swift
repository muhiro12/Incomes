@testable import IncomesLibrary
import Testing

struct WatchSyncWatermarkTests {
    @Test
    func successfulPull_advancesWatermarkWithoutRegressing() {
        var watermark = WatchSyncWatermark()

        watermark.recordPullResult(
            .success(items: []),
            request: request(baseEpoch: 200)
        )
        watermark.recordPullResult(
            .success(items: []),
            request: request(baseEpoch: 100)
        )

        #expect(watermark.latestEpoch == 200)
        #expect(!watermark.shouldApplyApplicationContext(generatedEpoch: 199))
        #expect(!watermark.shouldApplyApplicationContext(generatedEpoch: 200))
        #expect(watermark.shouldApplyApplicationContext(generatedEpoch: 201))
    }

    @Test
    func failedPull_doesNotAdvanceWatermark() {
        var watermark = WatchSyncWatermark()

        watermark.recordPullResult(
            .failed(
                phase: .transport,
                message: "Phone session is not reachable."
            ),
            request: request(baseEpoch: 200)
        )

        #expect(watermark.latestEpoch == nil)
        #expect(watermark.shouldApplyApplicationContext(generatedEpoch: 100))
    }

    @Test
    func successfulPull_usesPhoneEpochAcrossWatchClockSkew() {
        var watermark = WatchSyncWatermark()

        watermark.recordPullResult(
            .success(
                items: [],
                phoneGeneratedEpoch: 200
            ),
            request: request(baseEpoch: 20_000)
        )

        #expect(watermark.latestEpoch == 200)
        #expect(!watermark.shouldApplyApplicationContext(generatedEpoch: 199))
        #expect(!watermark.shouldApplyApplicationContext(generatedEpoch: 200))
        #expect(watermark.shouldApplyApplicationContext(generatedEpoch: 201))
    }

    @Test
    func delayedApplicationContext_cannotReplaceNewerLiveReply() {
        var watermark = WatchSyncWatermark()

        watermark.recordPullResult(
            .success(
                items: [],
                phoneGeneratedEpoch: 500
            ),
            request: request(baseEpoch: 100)
        )

        #expect(!watermark.shouldApplyApplicationContext(generatedEpoch: 499))
    }

    @Test
    func appliedApplicationContext_advancesWatermarkWithoutRegressing() {
        var watermark = WatchSyncWatermark()

        watermark.recordApplicationContextResult(
            .success(items: []),
            generatedEpoch: 300
        )
        watermark.recordApplicationContextResult(
            .success(items: []),
            generatedEpoch: 250
        )
        watermark.recordPullResult(
            .success(items: []),
            request: request(baseEpoch: 200)
        )

        #expect(watermark.latestEpoch == 300)
        #expect(!watermark.shouldApplyApplicationContext(generatedEpoch: 300))
        #expect(watermark.shouldApplyApplicationContext(generatedEpoch: 301))
    }

    @Test
    func failedApplicationContextApply_doesNotAdvanceWatermark() {
        var watermark = WatchSyncWatermark()

        watermark.recordApplicationContextResult(
            .failed(
                phase: .snapshotApply,
                message: "Snapshot could not be saved."
            ),
            generatedEpoch: 300
        )

        #expect(watermark.latestEpoch == nil)
        #expect(watermark.shouldApplyApplicationContext(generatedEpoch: 100))
    }

    @Test
    func applicationContextResult_prefersReplyPhoneEpoch() {
        var watermark = WatchSyncWatermark()

        watermark.recordApplicationContextResult(
            .success(
                items: [],
                phoneGeneratedEpoch: 400
            ),
            generatedEpoch: 40_000
        )

        #expect(watermark.latestEpoch == 400)
    }
}

private extension WatchSyncWatermarkTests {
    func request(
        baseEpoch: Double
    ) -> ItemsRequest {
        .init(
            baseEpoch: baseEpoch,
            monthOffsets: ItemsRequest.recentMonthOffsets
        )
    }
}
