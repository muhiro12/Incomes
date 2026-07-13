import Foundation
import MHPlatform

enum IncomesIntentRouteStore {
    static let appGroupStorageDescriptor: MHRawStorageDescriptor = {
        let descriptor = MHPreferenceDescriptors().pendingDeepLinkURL
        return .init(
            storageKey: descriptor.storageKey,
            defaultSelection: descriptor.defaultSelection
        )
    }()

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
