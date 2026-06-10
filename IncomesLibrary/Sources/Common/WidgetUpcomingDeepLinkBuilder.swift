import Foundation

/// Supplies deep-link builders used when constructing upcoming widget snapshots.
public struct WidgetUpcomingDeepLinkBuilder: Sendable {
    let homeDeepLink: @Sendable () -> URL
    let monthDeepLink: @Sendable (Date) -> URL
    let itemDeepLink: @Sendable (String) -> URL?

    /// Creates a builder for upcoming widget deep links.
    @preconcurrency
    public init(
        homeDeepLink: @escaping @Sendable () -> URL,
        monthDeepLink: @escaping @Sendable (Date) -> URL,
        itemDeepLink: @escaping @Sendable (String) -> URL?
    ) {
        self.homeDeepLink = homeDeepLink
        self.monthDeepLink = monthDeepLink
        self.itemDeepLink = itemDeepLink
    }
}
