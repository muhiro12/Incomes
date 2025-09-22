import Foundation
@testable import IncomesLibrary
import Testing

struct ItemWireTests {
    @Test
    func itemsRequest_roundTrips_via_JSON() throws {
        let req = ItemsRequest(baseEpoch: 1_725_000_000, monthOffsets: [-1, 0, 1])
        let data = try JSONEncoder().encode(req)
        let decoded = try #require(try? JSONDecoder().decode(ItemsRequest.self, from: data))
        #expect(decoded.baseEpoch == req.baseEpoch)
        #expect(decoded.monthOffsets == req.monthOffsets)
    }

    @Test
    func itemsPayload_roundTrips_via_JSON() throws {
        let items = [
            ItemWire(dateEpoch: 1_725_000_000, content: "Salary", income: 3_000, outgo: 0, category: "Salary"),
            ItemWire(dateEpoch: 1_725_086_400, content: "Rent", income: 0, outgo: 1_200, category: "Housing")
        ]
        let payload = ItemsPayload(items: items)
        let data = try JSONEncoder().encode(payload)
        let decoded = try #require(try? JSONDecoder().decode(ItemsPayload.self, from: data))
        #expect(decoded.items.count == 2)
        #expect(decoded.items.first?.content == "Salary")
        #expect(decoded.items.last?.category == "Housing")
    }
}
