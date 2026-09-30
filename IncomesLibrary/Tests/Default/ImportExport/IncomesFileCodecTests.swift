import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesFileCodecTests {
    @Test
    func round_trip_preserves_every_value() throws {
        let items = makeItems()
        let data = try encode(items)
        let contents = try ItemImportOperations.read(data: data)
        #expect(contents.items == IncomesFileItem.sortedByValue(items))
        #expect(contents.schemaVersion == "2.0.0")
        #expect(contents.currencyCode == "JPY")
        #expect(contents.exportedAt == exportedAt)
    }

    @Test
    func encoding_is_deterministic_and_independent_of_input_order() throws {
        let items = makeItems()
        #expect(try encode(items) == encode(items.reversed()))
        let contents = try ItemImportOperations.read(data: encode(items.reversed()))
        #expect(contents.items.map(\.content) == ["Salary", "Coffee ☕️", "Rent, \"home\"\nSecond line", ""])
    }

    @Test
    func file_uses_the_documented_shape_and_text_amounts() throws {
        let object = try jsonObject(encode(makeItems()))
        #expect(Set(object.keys) == ["exportedAt", "format", "items", "schemaVersion", "selection", "settings"])
        #expect(object["format"] as? String == "com.muhiro12.incomes.data")
        #expect(object["schemaVersion"] as? String == "2.0.0")
        #expect(object["exportedAt"] as? String == "2026-09-29T03:04:05Z")
        let selection = try #require(object["selection"] as? [String: Any])
        #expect((selection["filters"] as? [Any])?.isEmpty == true)
        let items = try #require(object["items"] as? [[String: Any]])
        let salary = try #require(items.first)
        #expect(salary["date"] as? String == "2026-03-07")
        #expect(salary["income"] as? String == "123456789012345")
        #expect(salary["outgo"] as? String == "0")
        #expect(salary["balance"] as? String == "123456789012345")
        #expect(salary["priority"] as? Int == 2)
    }

    @Test
    func empty_currency_omits_settings() throws {
        let data = try ItemExportOperations.incomesFileData(
            fileItems: makeItems(),
            currencyCode: "",
            exportedAt: exportedAt
        )
        #expect(try jsonObject(data)["settings"] == nil)
        #expect(try ItemImportOperations.read(data: data).currencyCode == nil)
    }

    @Test
    func unknown_keys_are_ignored_and_optional_values_may_be_absent() throws {
        let data = try modified { object in
            object["futureSection"] = ["value": 1]
            object["selection"] = nil
            var items = object["items"] as? [[String: Any]] ?? []
            items[0]["futureField"] = "ignored"
            items[0]["balance"] = nil
            object["items"] = items
        }
        let contents = try ItemImportOperations.read(data: data)
        #expect(contents.items.count == 4)
        #expect(contents.items.contains { item in
            item.content == "Salary" && item.balance == nil
        })
    }

    @Test(arguments: ["dateRange", "category", "unknownKind"])
    func any_selection_filter_is_rejected_as_must_understand(kind: String) throws {
        let data = try modified { object in
            object["selection"] = ["filters": [["kind": kind]]]
        }
        #expect(throws: ItemImportError.unsupportedSelection) {
            try ItemImportOperations.read(data: data)
        }
    }

    @Test(arguments: [
        ("3.0.0", ItemImportError.newerSchemaVersion("3.0.0")),
        ("2.1.0", ItemImportError.newerSchemaVersion("2.1.0")),
        ("1.0.0", ItemImportError.unsupportedSchemaVersion("1.0.0")),
        ("2.0", ItemImportError.malformedFile),
        ("2.0.0.0", ItemImportError.malformedFile),
        ("v2.0.0", ItemImportError.malformedFile)
    ])
    func schema_versions_outside_the_readable_set_are_rejected(
        version: String,
        error: ItemImportError
    ) throws {
        let data = try modified { object in
            object["schemaVersion"] = version
        }
        #expect(throws: error) {
            try ItemImportOperations.read(data: data)
        }
    }

    @Test
    func unrecognized_or_unreadable_data_is_rejected() throws {
        let valid = try encode(makeItems())
        let otherFormat = try modified { object in
            object["format"] = "com.example.other"
        }
        let inputs = [Data(), Data("not json".utf8), Data("[]".utf8), valid.prefix(valid.count / 2), otherFormat]
        for input in inputs {
            #expect(throws: ItemImportError.unrecognizedFormat) {
                try ItemImportOperations.read(data: Data(input))
            }
        }
    }

    @Test
    func oversized_data_is_rejected_before_parsing() {
        let data = Data(count: ItemImportOperations.maximumFileByteCount + 1)
        #expect(throws: ItemImportError.fileTooLarge) {
            try ItemImportOperations.read(data: data)
        }
    }

    @Test(arguments: [
        ("income", #""1e5""#),
        ("income", #""abc""#),
        ("income", #""1,000""#),
        ("income", #""1234567890123456""#),
        ("income", #""1.000000000000000000000000000000000000000000000000001""#),
        ("outgo", #""-1.000000000000000000000000000000000000000000000000001""#),
        ("balance", #""1.000000000000000000000000000000000000000000000000001""#),
        ("income", #"" 1""#),
        ("income", #""1.""#),
        ("outgo", #""--1""#),
        ("outgo", "12"),
        ("date", #""2026-02-30""#),
        ("date", #""2026-3-8""#),
        ("date", #""2026-03-08T00:00:00Z""#),
        ("repeatID", #""not-a-uuid""#),
        ("priority", #""1""#),
        ("content", "5"),
        ("category", "null"),
        ("balance", #""x""#)
    ])
    func invalid_item_values_report_their_index_and_field(key: String, json: String) throws {
        let value = try JSONSerialization.jsonObject(
            with: Data(json.utf8),
            options: .fragmentsAllowed
        )
        let data = try modified { object in
            var items = object["items"] as? [[String: Any]] ?? []
            items[1][key] = value
            object["items"] = items
        }
        let field = try #require(IncomesFileItem.Field(rawValue: key))
        #expect(throws: ItemImportError.invalidItem(index: 1, field: field)) {
            try ItemImportOperations.read(data: data)
        }
    }

    @Test
    func missing_item_values_report_their_index_and_field() throws {
        let data = try modified { object in
            var items = object["items"] as? [[String: Any]] ?? []
            items[2]["outgo"] = nil
            object["items"] = items
        }
        #expect(throws: ItemImportError.invalidItem(index: 2, field: .outgo)) {
            try ItemImportOperations.read(data: data)
        }
    }

    @Test(arguments: ["1.00000000000000000000000000000000000000000000000000", "00001.25000", "-0.01000"])
    func exact_amounts_with_redundant_zeros_are_accepted(text: String) throws {
        let data = try modified { object in
            var items = object["items"] as? [[String: Any]] ?? []
            items[0]["income"] = text
            object["items"] = items
        }
        let contents = try ItemImportOperations.read(data: data)
        let salary = try #require(contents.items.first { item in
            item.content == "Salary"
        })
        #expect(salary.income == Decimal(string: text, locale: .init(identifier: "en_US_POSIX")))
    }

    @Test
    func invalid_timestamp_is_malformed() throws {
        let data = try modified { object in
            object["exportedAt"] = "yesterday"
        }
        #expect(throws: ItemImportError.malformedFile) {
            try ItemImportOperations.read(data: data)
        }
    }
}

// swiftlint:disable no_magic_numbers
private extension IncomesFileCodecTests {
    var exportedAt: Date {
        isoDate("2026-09-29T03:04:05Z")
    }

    func makeItems() -> [IncomesFileItem] {
        [
            .init(
                date: isoDate("2026-03-08T00:00:00Z"),
                content: "Rent, \"home\"\nSecond line",
                income: .zero,
                outgo: Decimal(string: "80000.25") ?? .zero,
                category: "住まい",
                priority: 0,
                repeatID: uuid(1),
                balance: Decimal(string: "-1500.5")
            ),
            .init(
                date: isoDate("2026-03-07T00:00:00Z"),
                content: "Salary",
                income: Decimal(string: "123456789012345") ?? .zero,
                outgo: .zero,
                category: "Work",
                priority: 2,
                repeatID: uuid(2),
                balance: Decimal(string: "123456789012345")
            ),
            .init(
                date: isoDate("2026-03-09T00:00:00Z"),
                content: "",
                income: .zero,
                outgo: Decimal(string: "0.01") ?? .zero,
                category: "",
                priority: 0,
                repeatID: uuid(3),
                balance: nil
            ),
            .init(
                date: isoDate("2026-03-08T00:00:00Z"),
                content: "Coffee ☕️",
                income: .zero,
                outgo: -500,
                category: "Food",
                priority: 0,
                repeatID: uuid(1),
                balance: 0
            )
        ]
    }

    func uuid(_ value: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", value)) ?? UUID()
    }

    func encode(_ items: [IncomesFileItem]) throws -> Data {
        try ItemExportOperations.incomesFileData(
            fileItems: items,
            currencyCode: "JPY",
            exportedAt: exportedAt
        )
    }

    func jsonObject(_ data: Data) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func modified(_ change: (inout [String: Any]) -> Void) throws -> Data {
        var object = try jsonObject(encode(makeItems()))
        change(&object)
        return try JSONSerialization.data(withJSONObject: object)
    }
}

// swiftlint:enable no_magic_numbers
