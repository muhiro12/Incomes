#if DEBUG
import Foundation
import SwiftData

/// Keeps explicitly requested Store captures separate from phone synchronization.
enum WatchScreenshotSupport {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--incomes-screenshots")
    }

    static var presentsSettings: Bool {
        ProcessInfo.processInfo.arguments.contains("--incomes-screenshots-settings")
    }

    static let preferences: UserDefaults = {
        let suiteName = "Incomes.Watch.Screenshots.\(ProcessInfo.processInfo.processIdentifier)"
        guard let preferences = UserDefaults(suiteName: suiteName) else {
            preconditionFailure("Failed to prepare watch screenshot preferences")
        }
        preferences.removePersistentDomain(forName: suiteName)
        preferences.set(false, forKey: IncomesUserDefaultsKeys.Standard.isDebugOn.rawValue)
        preferences.set(Locale.current.currency?.identifier ?? "USD",
                        forKey: IncomesUserDefaultsKeys.Standard.currencyCode.rawValue)
        return preferences
    }()

    @MainActor
    static func makeModelContainer() -> ModelContainer {
        do {
            let sampleModelContainer = try ModelContainerFactory.inMemory()
            try SampleDataOperations.seedAndSave(
                context: sampleModelContainer.mainContext,
                profile: .standard,
                locale: .current
            )
            let baseDate = Date.now
            let items = try WatchSyncOperations.recentItemWires(
                context: sampleModelContainer.mainContext,
                baseDate: baseDate
            )
            let modelContainer = try ModelContainerFactory.inMemory()
            _ = try WatchSyncOperations.applySnapshotAndSave(
                context: modelContainer.mainContext,
                items: items,
                baseDate: baseDate
            )
            return modelContainer
        } catch {
            preconditionFailure("Failed to prepare watch screenshot data: \(error)")
        }
    }
}
#endif
