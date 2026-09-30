import Foundation
import MHPlatform
import SwiftData

/// Screen state for choosing, reviewing, and applying an Incomes file.
@MainActor
@Observable
final class DataImportModel {
    /// Policy offered when the store already contains items.
    enum PolicyChoice: Hashable, CaseIterable {
        case merge
        case replace
    }

    private(set) var contents: IncomesFileContents?
    private(set) var difference: ItemImportDifference?
    private(set) var isReading = false
    private(set) var isApplying = false
    private(set) var result: ItemImportResult?
    private(set) var isCloudSyncEnabled = false
    private(set) var currentCurrencyCode = ""

    var errorMessage: String?
    var policyChoice = PolicyChoice.merge
    var decisions = ItemImportMergeDecisions()
    var adoptsFileCurrency = false
}

extension DataImportModel {
    /// True when the file can be imported directly without choosing a policy.
    var isDirectImport: Bool {
        guard let difference else {
            return false
        }
        return difference.isStoreEmpty && !isCloudSyncEnabled
    }

    var policy: ItemImportPolicy {
        if isDirectImport {
            return .merge(.init())
        }
        switch policyChoice {
        case .merge:
            return .merge(decisions)
        case .replace:
            return .replace
        }
    }

    var plannedResult: ItemImportResult? {
        difference.map { difference in
            ItemImportOperations.result(difference: difference, policy: policy)
        }
    }

    /// Currency recorded in the file when it differs from the current setting.
    var differingFileCurrencyCode: String? {
        guard let fileCode = contents?.currencyCode,
              fileCode != currentCurrencyCode else {
            return nil
        }
        return fileCode
    }

    func read(
        _ selection: Result<URL, any Error>,
        context: ModelContext,
        currentCurrencyCode: String,
        logger: MHLogger
    ) async {
        reset()
        self.currentCurrencyCode = currentCurrencyCode
        isReading = true
        defer {
            isReading = false
        }
        do {
            let url = try selection.get()
            let contents = try await Task.detached(priority: .userInitiated) {
                try Self.readContents(at: url)
            }.value
            let difference = try ItemImportOperations.difference(contents: contents, context: context)
            self.contents = contents
            self.difference = difference
            isCloudSyncEnabled = Self.isCloudSyncEnabled(context: context)
            adoptsFileCurrency = difference.isStoreEmpty && differingFileCurrencyCode != nil
            logger.notice(
                "data_import.reviewed",
                metadata: IncomesLogging.metadata(
                    ("item_count", IncomesLogging.count(contents.items.count)),
                    ("matched_count", IncomesLogging.count(difference.matchedCount)),
                    ("change_group_count", IncomesLogging.count(difference.changeGroups.count)),
                    ("addition_count", IncomesLogging.count(difference.additions.count)),
                    ("store_only_count", IncomesLogging.count(difference.storeOnlyItems.count)),
                    ("icloud_enabled", IncomesLogging.bool(isCloudSyncEnabled))
                )
            )
        } catch {
            if (error as? CocoaError)?.code == .userCancelled {
                return
            }
            logger.error("data_import.read_failed", metadata: IncomesLogging.errorMetadata(error))
            errorMessage = Self.message(for: error)
        }
    }

    /// Applies the reviewed difference; returns true on success.
    func apply(
        context: ModelContext,
        didSave: @MainActor () -> Void,
        refreshNotificationSchedule: @escaping IncomesMutationWorkflow.NotificationScheduleRefresher,
        logger: MHLogger
    ) async -> Bool {
        guard !isReading, !isApplying,
              let contents,
              let difference else {
            return false
        }
        isApplying = true
        defer {
            isApplying = false
        }
        do {
            result = try await DataImportCoordinator.apply(
                .init(
                    contents: contents,
                    difference: difference,
                    policy: policy
                ),
                context: context,
                didSave: didSave,
                refreshNotificationSchedule: refreshNotificationSchedule,
                logger: logger
            )
            return true
        } catch ItemImportError.storeChangedSinceReview {
            errorMessage = Self.message(for: ItemImportError.storeChangedSinceReview)
            reviewAgain(context: context)
            return false
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }

    func isAdditionIncluded(at index: Int) -> Bool {
        !decisions.excludedAdditionIndices.contains(index)
    }

    func setAddition(at index: Int, isIncluded: Bool) {
        if isIncluded {
            decisions.excludedAdditionIndices.remove(index)
        } else {
            decisions.excludedAdditionIndices.insert(index)
        }
    }

    func resolution(for key: ItemImportChangeGroupKey) -> ItemImportMergeDecisions.Resolution {
        decisions.resolution(for: key)
    }

    func setResolution(
        _ resolution: ItemImportMergeDecisions.Resolution,
        for key: ItemImportChangeGroupKey
    ) {
        decisions.resolutions[key] = resolution
    }

    func reset() {
        contents = nil
        difference = nil
        result = nil
        errorMessage = nil
        policyChoice = .merge
        decisions = .init()
        adoptsFileCurrency = false
    }

    /// A currency change needs a fresh choice before import can replace that setting.
    func validateCurrencyForApply(_ currencyCode: String) -> Bool {
        guard currencyCode == currentCurrencyCode else {
            currentCurrencyCode = currencyCode
            adoptsFileCurrency = false
            errorMessage = Self.message(for: ItemImportError.storeChangedSinceReview)
            return false
        }
        return true
    }
}

private extension DataImportModel {
    nonisolated static func readContents(at url: URL) throws -> IncomesFileContents {
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? .zero
        guard fileSize <= ItemImportOperations.maximumFileByteCount else {
            throw ItemImportError.fileTooLarge
        }
        return try ItemImportOperations.read(data: .init(contentsOf: url))
    }

    static func isCloudSyncEnabled(context: ModelContext) -> Bool {
        context.container.configurations.contains { configuration in
            configuration.cloudKitContainerIdentifier != nil
        }
    }

    static func message(for error: any Error) -> String {
        if error is ItemImportError || error is ItemAmountError {
            return error.localizedDescription
        }
        return String(localized: "The file could not be imported. Your data has not changed.")
    }

    /// Recalculates the difference after the store changed, keeping the chosen policy.
    func reviewAgain(context: ModelContext) {
        guard let contents else {
            return
        }
        do {
            difference = try ItemImportOperations.difference(contents: contents, context: context)
            decisions = .init()
            adoptsFileCurrency = false
        } catch {
            errorMessage = Self.message(for: error)
        }
    }
}
