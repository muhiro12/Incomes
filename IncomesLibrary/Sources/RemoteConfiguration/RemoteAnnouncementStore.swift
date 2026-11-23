import Foundation
import MHPlatformCore
import Observation

/// The last announcement section observed in this process, shared by its windows.
@preconcurrency
@MainActor
@Observable
public final class RemoteAnnouncementStore {
    private static let lifetime: TimeInterval = 86_400

    private var latest: MHRemoteConfigResponse<MHAnnouncementFeed?>?

    /// Whether a validated feed is available for time-based presentation.
    public var hasFeed: Bool {
        latest?.value != nil
    }

    /// Starts without retaining notices from an earlier app launch.
    public init() {
        latest = nil
    }

    /// Replaces the previous publication, clearing it for missing or invalid sections.
    public func receive(_ response: MHRemoteConfigResponse<MHRemoteConfigSection<MHAnnouncementFeed>>) {
        latest = response.map { section in
            try? section.get()
        }
    }

    /// Selects active localized notices for up to one day after their original fetch.
    public func visibleAnnouncements(
        installedVersion: MHAppVersion?,
        at date: Date,
        appLanguage: String?,
        preferredLanguages: [String]
    ) -> [MHAnnouncement] {
        guard let latest, let feed = latest.value,
              (0..<Self.lifetime).contains(date.timeIntervalSince(latest.fetchedAt)) else {
            return []
        }
        return feed.visibleAnnouncements(
            installedVersion: installedVersion,
            at: date,
            preferredLanguages: languagePreferences(appLanguage: appLanguage, preferredLanguages: preferredLanguages)
        )
    }

    private func languagePreferences(appLanguage: String?, preferredLanguages: [String]) -> [String] {
        guard let appLanguage else {
            return preferredLanguages
        }
        let activeLanguage = Locale.Language(identifier: appLanguage)
        let matchingLanguages = preferredLanguages.filter { identifier in
            let language = Locale.Language(identifier: identifier)
            return language.languageCode == activeLanguage.languageCode && language.script == activeLanguage.script
        }
        return matchingLanguages + [appLanguage] + preferredLanguages
    }
}
