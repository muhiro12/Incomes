import Foundation
import MHPlatform

enum IncomesPendingDeepLinkSupport {
    private struct NotificationPendingDeepLinkSource: MHDeepLinkURLSource, @unchecked Sendable {
        let notificationService: NotificationService

        func consumeLatestURL() async -> URL? {
            await notificationService.consumePendingDeepLinkURL()
        }
    }

    static func consumeLatestURL(
        notificationService: NotificationService
    ) async -> URL? {
        let sourceChain = MHDeepLinkSourceChain(
            pendingSources(notificationService: notificationService)
        )
        return await sourceChain.consumeLatestURL()
    }

    private static func pendingSources(
        notificationService: NotificationService
    ) -> [any MHDeepLinkURLSource] {
        var sources = [any MHDeepLinkURLSource]()

        if let intentRouteSource = IncomesIntentRouteStore.source {
            sources.append(intentRouteSource)
        }

        sources.append(
            NotificationPendingDeepLinkSource(
                notificationService: notificationService
            )
        )

        return sources
    }
}
