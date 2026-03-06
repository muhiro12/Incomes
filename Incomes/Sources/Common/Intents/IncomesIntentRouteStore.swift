import Foundation
import MHPlatform

enum IncomesIntentRouteStore {
    private static let pendingDeepLinkURLKey = "pendingIntentDeepLinkURL"
    private static var deepLinkStore: MHDeepLinkStore? {
        guard let userDefaults = UserDefaults(suiteName: AppGroup.id) else {
            return nil
        }
        return .init(
            userDefaults: userDefaults,
            key: pendingDeepLinkURLKey
        )
    }

    static func store(_ url: URL) {
        deepLinkStore?.ingest(url)
    }

    static func consume() -> URL? {
        deepLinkStore?.consumeLatest()
    }
}
