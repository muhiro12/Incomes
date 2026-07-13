import Foundation
@testable import IncomesLibrary
import Testing

struct WatchSyncApplicationContextTests {
    @Test
    func applicationContext_roundTripsRequestReplyAndCurrency() throws {
        let request = ItemsRequest(
            baseEpoch: 1_725_000_000,
            monthOffsets: [-1, 0, 1]
        )
        let reply = WatchSyncReply.success(
            items: [
                .init(
                    dateEpoch: 1_725_000_000,
                    content: "Salary",
                    income: 3_000,
                    outgo: 0,
                    category: "Income"
                )
            ],
            currencyCode: "USD"
        )

        let applicationContext = try WatchSyncApplicationContext.make(
            request: request,
            reply: reply
        )
        let snapshot = try WatchSyncApplicationContext.snapshot(
            from: applicationContext
        )

        #expect(snapshot.request.baseEpoch == request.baseEpoch)
        #expect(snapshot.request.monthOffsets == request.monthOffsets)
        #expect(snapshot.generatedEpoch > 0)
        #expect(snapshot.reply.phoneGeneratedEpoch == snapshot.generatedEpoch)
        #expect(snapshot.reply.items.first?.income == 3_000)
        #expect(snapshot.reply.currencyCode == "USD")
    }

    @Test
    func applicationContext_decodesLegacyReplyWithoutPhoneEpoch() throws {
        let data = Data(
            """
            {
              "schemaVersion": 1,
              "id": "0D6EE72C-12A8-40B6-9DAB-3B95A59364E0",
              "generatedEpoch": 1725000100,
              "request": {
                "baseEpoch": 1725000000,
                "monthOffsets": [-1, 0, 1]
              },
              "reply": {
                "status": "success",
                "items": [],
                "failure": null
              }
            }
            """.utf8
        )
        let applicationContext: [String: Any] = [
            "com.muhiro12.Incomes.watchSyncSnapshot": data
        ]

        let snapshot = try WatchSyncApplicationContext.snapshot(
            from: applicationContext
        )

        #expect(snapshot.generatedEpoch == 1_725_000_100)
        #expect(snapshot.reply.phoneGeneratedEpoch == nil)
    }

    @Test
    func applicationContext_trimsDeterministicPrefixToEncodedByteLimit() throws {
        let request = ItemsRequest(
            baseEpoch: 1_725_000_000,
            monthOffsets: [-1, 0, 1]
        )
        let items = longItems(count: 5)
        let generationEpoch = 1_725_000_100.0
        let twoItemReply = WatchSyncReply.success(
            items: Array(items.prefix(2)),
            currencyCode: "USD",
            phoneGeneratedEpoch: generationEpoch
        )
        let twoItemContext = try WatchSyncApplicationContext.prepare(
            request: request,
            reply: twoItemReply,
            maximumPayloadByteCount: .max,
            phoneGeneratedEpoch: generationEpoch
        )
        let fullReply = WatchSyncReply.success(
            items: items,
            currencyCode: "USD",
            phoneGeneratedEpoch: generationEpoch
        )

        let firstContext = try WatchSyncApplicationContext.prepare(
            request: request,
            reply: fullReply,
            maximumPayloadByteCount: twoItemContext.payloadByteCount,
            phoneGeneratedEpoch: generationEpoch
        )
        let secondContext = try WatchSyncApplicationContext.prepare(
            request: request,
            reply: fullReply,
            maximumPayloadByteCount: twoItemContext.payloadByteCount,
            phoneGeneratedEpoch: generationEpoch
        )
        let firstSnapshot = try WatchSyncApplicationContext.snapshot(
            from: firstContext.applicationContext
        )
        let secondSnapshot = try WatchSyncApplicationContext.snapshot(
            from: secondContext.applicationContext
        )

        #expect(firstContext.includedItemCount == 2)
        #expect(secondContext.includedItemCount == 2)
        #expect(firstContext.payloadByteCount <= twoItemContext.payloadByteCount)
        #expect(secondContext.payloadByteCount <= twoItemContext.payloadByteCount)
        #expect(firstSnapshot.reply.items.map(\.content) == items.prefix(2).map(\.content))
        #expect(secondSnapshot.reply.items.map(\.content) == items.prefix(2).map(\.content))
    }

    @Test
    func applicationContext_defaultBudgetBoundsLongItemPayload() throws {
        let items = longItems(count: 20)
        let reply = WatchSyncReply.success(
            items: items,
            currencyCode: "JPY",
            phoneGeneratedEpoch: 1_725_000_100
        )

        let preparedContext = try WatchSyncApplicationContext.prepare(
            request: .init(
                baseEpoch: 1_725_000_000,
                monthOffsets: [-1, 0, 1]
            ),
            reply: reply
        )

        #expect(
            preparedContext.payloadByteCount
                <= WatchSyncApplicationContext.maximumPayloadByteCount
        )
        #expect(preparedContext.includedItemCount < items.count)
    }

    @Test
    func applicationContext_requiresPayload() {
        #expect(
            throws: WatchSyncApplicationContext.ContextError.missingPayload
        ) {
            _ = try WatchSyncApplicationContext.snapshot(from: [:])
        }
    }
}

private extension WatchSyncApplicationContextTests {
    func longItems(
        count: Int
    ) -> [ItemWire] {
        let baseEpoch = 1_725_000_000.0
        let contentRepetitionCount = 300
        let categoryRepetitionCount = 150

        return (0..<count).map { itemIndex in
            .init(
                dateEpoch: baseEpoch + Double(itemIndex),
                content: "Item \(itemIndex) "
                    + String(
                        repeating: "Long content ",
                        count: contentRepetitionCount
                    ),
                income: Decimal(itemIndex),
                outgo: 0,
                category: "Category \(itemIndex) "
                    + String(
                        repeating: "Long category ",
                        count: categoryRepetitionCount
                    )
            )
        }
    }
}
