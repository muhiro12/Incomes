import Foundation
import MHPlatform

enum IncomesIntentRouteStore {
    private static let pendingDeepLinkURLKey = "pendingIntentDeepLinkURL"
    private static let deepLinkStore = UserDefaults(
        suiteName: AppGroup.id
    ).map { userDefaults in
        MHDeepLinkStore(
            userDefaults: userDefaults,
            key: pendingDeepLinkURLKey
        )
    }

    static var source: MHDeepLinkStore? {
        deepLinkStore
    }

    static func store(_ url: URL) {
        deepLinkStore?.ingest(url)
    }
}
