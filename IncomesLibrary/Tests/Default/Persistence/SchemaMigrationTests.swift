import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct SchemaMigrationTests {
    private let historicalDate = Date(timeIntervalSinceReferenceDate: 123_456)
    private let historicalPriority = 7
    private let currentSchemaVersion = 2
    private let expectedItemCount = 2

    @Test(arguments: [0, 1, 2])
    func unversionedStorePreservesValuesAndRelationships(version: Int) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let url = directory.appendingPathComponent("Incomes.sqlite")
        let repeatID = UUID()
        let identifier = try seedUnversionedStore(at: url, version: version, repeatID: repeatID)

        if version < currentSchemaVersion {
            #expect(throws: (any Error).self) {
                try ModelContainerFactory.readOnly(at: url)
            }
        }

        try verifyStore(at: url, version: version, repeatID: repeatID, identifier: identifier)
        try verifyReadOnlyStore(at: url)
        // Release the container and reopen again to verify durable, repeatable startup.
        try verifyStore(at: url, version: version, repeatID: repeatID, identifier: identifier)
    }

    @Test
    func extensionDoesNotCreateMissingStore() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let url = directory.appendingPathComponent("Incomes.sqlite")
        #expect(throws: CocoaError.self) {
            try ModelContainerFactory.readOnly(at: url)
        }
        #expect(!FileManager.default.fileExists(atPath: url.path))
        let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Item>()) == 0)
    }

    @Test
    func deletingSharedTagPreservesItemsAfterReopening() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let url = directory.appendingPathComponent("Incomes.sqlite")
        _ = try seedUnversionedStore(at: url, version: currentSchemaVersion, repeatID: UUID())
        try deleteSharedTag(at: url)
        let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        let items = try container.mainContext.fetch(FetchDescriptor<Item>())
        #expect(items.count == expectedItemCount)
        #expect(items.allSatisfy { ($0.tags ?? []).isEmpty })
        #expect(try container.mainContext.fetchCount(FetchDescriptor<IncomesLibrary.Tag>()) == 0)
    }
}

private extension SchemaMigrationTests {
    func seedUnversionedStore(at url: URL, version: Int, repeatID: UUID) throws -> String {
        switch version {
        case 0:
            try seedV0(at: url, repeatID: repeatID)
        case 1:
            try seedV1(at: url, repeatID: repeatID)
        default:
            try seedV2(at: url, repeatID: repeatID)
        }
    }

    func seedV0(at url: URL, repeatID: UUID) throws -> String {
        let container = try ModelContainer(
            for: UnversionedStoreV0.Item.self,
            configurations: .init(url: url, cloudKitDatabase: .none)
        )
        let context = container.mainContext
        let tag = UnversionedStoreV0.Tag()
        tag.name = "Shared category"
        tag.typeID = "a7a130f4"
        let item = UnversionedStoreV0.Item()
        context.insert(item)
        item.date = historicalDate
        item.content = "Historical income"
        item.income = Decimal(string: "12345.67") ?? .zero
        item.outgo = Decimal(string: "89.12") ?? .zero
        item.balance = Decimal(string: "-42.25") ?? .zero
        item.repeatID = repeatID
        item.tags = [tag]
        let second = UnversionedStoreV0.Item()
        context.insert(second)
        second.tags = [tag]
        second.repeatID = repeatID
        try context.save()
        return try PersistentIdentifierCoder.encode(item.persistentModelID)
    }

    func seedV1(at url: URL, repeatID: UUID) throws -> String {
        let container = try ModelContainer(
            for: UnversionedStoreV1.Item.self,
            configurations: .init(url: url, cloudKitDatabase: .none)
        )
        let context = container.mainContext
        let tag = UnversionedStoreV1.Tag()
        tag.name = "Shared category"
        tag.typeID = "a7a130f4"
        let item = UnversionedStoreV1.Item()
        context.insert(item)
        item.date = historicalDate
        item.content = "Historical income"
        item.income = Decimal(string: "12345.67") ?? .zero
        item.outgo = Decimal(string: "89.12") ?? .zero
        item.balance = Decimal(string: "-42.25") ?? .zero
        item.repeatID = repeatID
        item.tags = [tag]
        let second = UnversionedStoreV1.Item()
        context.insert(second)
        second.tags = [tag]
        second.repeatID = repeatID
        try context.save()
        return try PersistentIdentifierCoder.encode(item.persistentModelID)
    }

    func seedV2(at url: URL, repeatID: UUID) throws -> String {
        let container = try ModelContainer(
            for: UnversionedStoreV2.Item.self,
            configurations: .init(url: url, cloudKitDatabase: .none)
        )
        let context = container.mainContext
        let tag = UnversionedStoreV2.Tag()
        tag.name = "Shared category"
        tag.typeID = "a7a130f4"
        let item = UnversionedStoreV2.Item()
        context.insert(item)
        item.date = historicalDate
        item.content = "Historical income"
        item.income = Decimal(string: "12345.67") ?? .zero
        item.outgo = Decimal(string: "89.12") ?? .zero
        item.balance = Decimal(string: "-42.25") ?? .zero
        item.priority = historicalPriority
        item.repeatID = repeatID
        item.tags = [tag]
        let second = UnversionedStoreV2.Item()
        context.insert(second)
        second.tags = [tag]
        second.repeatID = repeatID
        try context.save()
        return try PersistentIdentifierCoder.encode(item.persistentModelID)
    }

    func verifyStore(at url: URL, version: Int, repeatID: UUID, identifier: String) throws {
        let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        let context = container.mainContext
        let items = try context.fetch(FetchDescriptor<Item>())
        #expect(items.count == expectedItemCount)
        let item = try #require(items.first { $0.content == "Historical income" })
        #expect(try PersistentIdentifierCoder.encode(item.persistentModelID) == identifier)
        let decodedIdentifier = try PersistentIdentifierCoder.decode(identifier)
        let resolvedItem = context.model(for: decodedIdentifier) as? Item
        #expect(resolvedItem?.content == item.content)
        #expect(item.utcDate == historicalDate)
        #expect(item.income == Decimal(string: "12345.67"))
        #expect(item.outgo == Decimal(string: "89.12"))
        #expect(item.balance == Decimal(string: "-42.25"))
        #expect(item.repeatID == repeatID)
        #expect(item.priority == (version < currentSchemaVersion ? 0 : historicalPriority))
        let tag = try #require(item.tags?.first)
        #expect(tag.name == "Shared category")
        #expect(tag.typeID == "a7a130f4")
        #expect(tag.items?.count == expectedItemCount)
        #expect(try context.fetchCount(FetchDescriptor<IncomesLibrary.Tag>()) == 1)
    }

    func verifyReadOnlyStore(at url: URL) throws {
        let container = try ModelContainerFactory.readOnly(at: url)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Item>()) == expectedItemCount)
        #expect(container.configurations.allSatisfy { !$0.allowsSave })
    }

    func deleteSharedTag(at url: URL) throws {
        let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        let context = container.mainContext
        let tag = try #require(context.fetch(FetchDescriptor<IncomesLibrary.Tag>()).first)
        context.delete(tag)
        try context.save()
    }
}
