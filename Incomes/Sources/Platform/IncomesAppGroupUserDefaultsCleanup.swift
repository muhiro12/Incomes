import Foundation
import MHPlatform

enum IncomesAppGroupUserDefaultsCleanup {
    @MainActor
    static func removeUnknownKeys() {
        guard let userDefaults = UserDefaults(suiteName: AppGroup.id) else {
            return
        }

        _ = MHUserDefaultsCleanupService.removeUnknownKeys(
            from: userDefaults,
            domainName: AppGroup.id,
            knownDescriptors: knownDescriptors
        )
    }
}

private extension IncomesAppGroupUserDefaultsCleanup {
    static let knownDescriptors: [MHRawStorageDescriptor] = [
        IncomesIntentRouteStore.appGroupStorageDescriptor
    ]
}
