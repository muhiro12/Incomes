import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct WatchSyncOrderingTests {
    @Test
    func snapshot_preserves_priority_and_same_day_sequence_after_encoding_and_reopening() throws {
        let source = ModelContext(try ModelContainerFactory.inMemory())
        let date = shiftedDate("2024-01-10T12:00:00Z")
        for (content, priority) in [("Entry 10", 0), ("Entry 2", 0), ("Priority", 10)] {
            _ = try Item.create(
                context: source,
                values: .init(date: date, content: content, income: 1, outgo: .zero, category: "", priority: priority),
                repeatID: UUID()
            )
        }
        try source.save()
        try ItemBalanceOperations.recalculateAndSave(context: source, date: date)
        let expected = try source.fetch(.items(.all, order: .forward))
        let wires = try WatchSyncOperations.recentItemWires(context: source, baseDate: date, monthOffsets: [0])
        let payload = try WatchSyncReply.responseData(for: .success(items: wires))
        let decoded = WatchSyncReply.decodeResponse(payload)
        #expect(decoded.shouldApplySnapshot)
        let destination = ModelContext(try ModelContainerFactory.inMemory())
        _ = try WatchSyncOperations.applySnapshot(
            context: destination, items: decoded.items, baseDate: date, monthOffsets: [0]
        )
        try destination.save()
        let restored = try ModelContext(destination.container).fetch(.items(.all, order: .forward))
        #expect(restored.map(\.content) == ["Priority", "Entry 2", "Entry 10"])
        #expect(restored.map(\.priority) == expected.map(\.priority))
        #expect(restored.map(\.balance) == expected.map(\.balance))
    }

    @Test
    func legacy_snapshot_without_priority_still_decodes_and_applies() throws {
        let data = Data(#"{"dateEpoch":1704844800,"content":"Old phone","income":1,"outgo":0,"category":""}"#.utf8)
        let wire = try JSONDecoder().decode(ItemWire.self, from: data)
        #expect(wire.priority == 0)
        let context = ModelContext(try ModelContainerFactory.inMemory())
        _ = try WatchSyncOperations.applySnapshot(
            context: context, items: [wire], baseDate: Date(timeIntervalSince1970: wire.dateEpoch), monthOffsets: [0]
        )
        try context.save()
        #expect(try ModelContext(context.container).fetch(.items(.all)).first?.priority == 0)
    }
}
