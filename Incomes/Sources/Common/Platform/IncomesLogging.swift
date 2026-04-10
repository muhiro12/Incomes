import Foundation
import MHPlatform

enum IncomesLogging {
    enum Category {
        nonisolated static let appIntent = "AppIntent"
        nonisolated static let appStartup = "AppStartup"
        nonisolated static let dataMaintenance = "DataMaintenance"
        nonisolated static let inference = "Inference"
        nonisolated static let itemMutation = "ItemMutation"
        nonisolated static let mainNavigationSidebar = "MainNavigationSidebar"
        nonisolated static let mainNavigationYearDeletion = "MainNavigationYearDeletion"
        nonisolated static let notification = "Notification"
        nonisolated static let notificationRoute = "NotificationRoute"
        nonisolated static let remoteConfiguration = "RemoteConfiguration"
        nonisolated static let reviewFlow = "ReviewFlow"
        nonisolated static let routeExecution = "RouteExecution"
        nonisolated static let watchSync = "WatchSync"
        nonisolated static let yearlyDuplication = "YearlyDuplication"
    }

    private static let snapshotKey = MHCodablePreferenceKey<[MHLogEvent]>(
        storageKey: "incomes.logging.snapshot"
    )

    static var policy: MHLogPolicy {
        #if DEBUG
        .debugDefault
        #else
        .init(
            minimumLevel: .warning,
            maximumInMemoryEvents: MHLogPolicy.releaseDefault.maximumInMemoryEvents
        )
        #endif
    }

    @MainActor
    static func makeBootstrap() -> MHLoggingBootstrap {
        let userDefaults = UserDefaults(suiteName: AppGroup.id) ?? .standard
        return .init(
            policy: policy,
            subsystem: Bundle.main.bundleIdentifier,
            snapshotKey: snapshotKey,
            snapshotStore: .init(userDefaults: userDefaults)
        )
    }

    @MainActor
    static func logger(
        logging: MHLoggingBootstrap,
        category: String,
        source: String = #fileID
    ) -> MHLogger {
        logging.logger(
            category: category,
            source: source
        )
    }

    nonisolated static func metadata(
        _ pairs: (String, String?)...
    ) -> [String: String] {
        pairs.reduce(into: [String: String]()) { partialResult, pair in
            if let value = pair.1 {
                partialResult[pair.0] = value
            }
        }
    }

    nonisolated static func bool(_ value: Bool) -> String {
        value ? "true" : "false"
    }

    nonisolated static func count(_ value: Int) -> String {
        String(value)
    }

    nonisolated static func optionalInt(_ value: Int?) -> String? {
        value.map(String.init)
    }

    nonisolated static func presence(_ value: String?) -> String {
        guard let value,
              value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return "missing"
        }
        return "present"
    }

    nonisolated static func errorMetadata(
        _ error: any Error
    ) -> [String: String] {
        let errorValue = error as NSError
        return metadata(
            ("error_type", String(describing: type(of: error))),
            ("error_domain", errorValue.domain),
            ("error_code", String(errorValue.code))
        )
    }
}
