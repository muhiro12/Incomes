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
    static let knownDescriptors: [MHRawStorageDescriptor] = {
        let descriptors = MHPreferenceDescriptors()
        return [
            descriptors.currencyCode,
            descriptors.pendingDeepLinkURL
        ].map { descriptor in
            .init(
                storageKey: descriptor.storageKey,
                defaultSelection: descriptor.defaultSelection
            )
        }
    }()
}
