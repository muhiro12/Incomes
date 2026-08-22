import Foundation
@testable import IncomesLibrary
import Testing

struct WatchSyncRefreshSignalTests {
    @Test
    func applicationContext_roundTripsSignalID() throws {
        let signal = WatchSyncRefreshSignal(
            id: try #require(UUID(uuidString: "5E8653BB-B184-4734-819A-83B0C2E26A36"))
        )

        let decodedSignal = try #require(
            WatchSyncRefreshSignal(
                applicationContext: signal.applicationContext
            )
        )

        #expect(decodedSignal == signal)
    }

    @Test
    func applicationContext_rejectsMissingOrMalformedSignalID() {
        #expect(WatchSyncRefreshSignal(applicationContext: [:]) == nil)
        #expect(
            WatchSyncRefreshSignal(
                applicationContext: ["watchSyncRefreshSignalID": "invalid"]
            ) == nil
        )
    }
}
