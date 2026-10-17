import Foundation
import SwiftData

/// Manages independent books through dedicated Tags without extending the stored model.
public enum LedgerOperations {
    /// A ledger Tag keeps its native model identity through edits and renames.
    public static func identifier(for tag: Tag) -> LedgerIdentifier? {
        LedgerTagStorage.identifier(for: tag)
    }

    /// Includes empty ledgers and surfaces conflicting Item membership.
    public static func ledgers(context: ModelContext) throws -> [LedgerRecord] {
        let tags = try context.fetch(.tags(.typeIs(.ledger)))
        var identifiers = Set(tags.compactMap(LedgerTagStorage.identifier(for:)))
        if try context.fetch(.allLedgerItems()).contains(where: { $0.ledgerIdentifier == .conflicting }) {
            identifiers.insert(.conflicting)
        }
        identifiers.insert(.default)
        return identifiers.map { record(identifier: $0, tags: tags) }
            .sorted { left, right in
                if left.id == .default || right.id == .default {
                    return left.id == .default
                }
                return (left.name, left.id.rawValue) < (right.name, right.id.rawValue)
            }
    }

    /// Resolves the Tag's store-local identity without matching an editable name.
    public static func ledger(_ identifier: LedgerIdentifier, context: ModelContext) throws -> LedgerRecord {
        record(identifier: identifier, tags: try context.fetch(.tags(.typeIs(.ledger))))
    }

    /// Creates and saves one empty book without changing any existing Items.
    public static func create(context: ModelContext, name: String) throws -> LedgerRecord {
        try requireCleanContext(context)
        let name = try validatedName(name)
        guard try context.fetch(.tags(.nameIs(name, type: .ledger))).isEmpty else {
            throw LedgerError.duplicateName
        }
        let autosaveEnabled = context.autosaveEnabled
        context.autosaveEnabled = false
        defer {
            context.autosaveEnabled = autosaveEnabled
        }
        do {
            let tag = Tag.createLedger(context: context, name: name)
            try context.save()
            guard let identifier = LedgerTagStorage.identifier(for: tag) else {
                throw LedgerError.invalidIdentifier
            }
            return .init(id: identifier, name: name)
        } catch {
            context.rollback()
            throw error
        }
    }

    /// Renames additional-book metadata without replacing its relationships or identity.
    public static func rename(_ identifier: LedgerIdentifier, to name: String, context: ModelContext) throws {
        try requireCleanContext(context)
        let name = try validatedName(name)
        let metadata = try metadataForMutation(identifier, context: context)
        guard try context.fetch(.tags(.nameIs(name, type: .ledger))).allSatisfy({ $0.id == metadata.id }) else {
            throw LedgerError.duplicateName
        }
        let autosaveEnabled = context.autosaveEnabled
        context.autosaveEnabled = false
        defer {
            context.autosaveEnabled = autosaveEnabled
        }
        do {
            metadata.rename(storedName: name)
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    /// Entitlement remains adapter-owned; missing or conflicting books refuse mutation.
    public static func requireAvailable(_ identifier: LedgerIdentifier, context: ModelContext) throws {
        if let issue = try ledger(identifier, context: context).issue {
            throw issue
        }
    }
}

extension LedgerOperations {
    @discardableResult
    static func importMetadata(_ value: IncomesFileLedger, context: ModelContext) throws -> Tag {
        guard value.id != .default, value.id != .conflicting, !value.id.rawValue.isEmpty else {
            throw LedgerError.invalidIdentifier
        }
        let name = try validatedName(value.name)
        let matches = try context.fetch(.tags(.typeIs(.ledger)))
            .filter { tag in
                LedgerTagStorage.identifier(for: tag) == value.id
            }
        guard matches.count <= 1 else {
            throw LedgerError.duplicateIdentifier
        }
        if let metadata = matches.first {
            metadata.rename(storedName: name)
            return metadata
        }
        return Tag.createLedger(context: context, name: name)
    }

    static func metadataForMutation(_ identifier: LedgerIdentifier, context: ModelContext) throws -> Tag {
        guard identifier != .default else {
            throw LedgerError.protectedMetadata
        }
        let matches = try context.fetch(.tags(.typeIs(.ledger)))
            .filter { tag in
                LedgerTagStorage.identifier(for: tag) == identifier
            }
        guard matches.count <= 1 else {
            throw LedgerError.duplicateIdentifier
        }
        guard let metadata = matches.first else {
            throw LedgerError.unavailable
        }
        return metadata
    }

    static func requireCleanContext(_ context: ModelContext) throws {
        guard !context.hasChanges else {
            throw LedgerError.pendingChanges
        }
        guard context.container.configurations.allSatisfy(\.allowsSave) else {
            throw CocoaError(.fileWriteNoPermission)
        }
    }

    static func record(identifier: LedgerIdentifier, tags: [Tag]) -> LedgerRecord {
        if identifier == .default {
            return .init(id: identifier, name: String(localized: "Default Ledger", bundle: .module))
        }
        if identifier == .conflicting {
            return .init(
                id: identifier,
                name: String(localized: "Conflicting Ledger", bundle: .module),
                issue: .conflictingOwnership
            )
        }
        let matches = tags.filter { LedgerTagStorage.identifier(for: $0) == identifier }
        guard matches.count <= 1 else {
            return .init(
                id: identifier,
                name: String(localized: "Conflicting Ledger", bundle: .module),
                issue: .duplicateIdentifier
            )
        }
        guard let metadata = matches.first else {
            return .init(
                id: identifier,
                name: String(localized: "Unavailable Ledger", bundle: .module),
                issue: .unavailable
            )
        }
        return .init(id: identifier, name: metadata.name)
    }

    static func validatedName(_ name: String) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw LedgerError.invalidName
        }
        return trimmed
    }
}
