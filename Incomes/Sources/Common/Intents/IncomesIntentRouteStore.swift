import Foundation
import MHPlatform

enum IncomesIntentRouteStore {
    private enum StorageKey {
        static let pendingDeepLinkURL = "d2T9w4Bn"
    }

    static let appGroupStorageDescriptor = MHRawStorageDescriptor(
        storageKey: StorageKey.pendingDeepLinkURL,
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
