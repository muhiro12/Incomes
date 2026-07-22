import Foundation
import MHPlatform

enum IncomesIntentRouteStore {
    static let appGroupStorageDescriptor = MHRawStorageDescriptor(
        storageKey: IncomesUserDefaultsKeys.AppGroup.pendingDeepLinkURL.rawValue,
        defaultSelection: .suite(AppGroup.id)
    )

    private static let deepLinkStore = MHDeepLinkStore(
        key: appGroupStorageDescriptor
    )

    static var source: MHDeepLinkStore? {
        deepLinkStore
    }

    static func store(_ url: URL) {
        deepLinkStore.ingest(url)
    }
}
