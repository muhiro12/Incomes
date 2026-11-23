import Foundation
import IncomesLibrary
import MHPlatformCore
import Testing

@MainActor
struct RemoteAnnouncementStoreTests {
    private let fetchedAt = Date(timeIntervalSince1970: 1_000)

    @Test
    func displaysLocalizedNoticesWithinPublicationAndFreshnessWindows() throws {
        let store = RemoteAnnouncementStore()
        let feed = try decodeFeed()
        store.receive(.init(value: .value(feed), fetchedAt: fetchedAt))

        func titles(_ offset: TimeInterval, version: String = "6.4") -> [String] {
            store.visibleAnnouncements(
                installedVersion: MHAppVersion(version),
                at: fetchedAt.addingTimeInterval(offset),
                appLanguage: "ja",
                preferredLanguages: ["ja-JP"]
            )
            .map(\.title)
        }

        #expect(titles(-1).isEmpty)
        #expect(titles(0) == ["General"])
        #expect(titles(1) == ["月額プラン", "General"])
        #expect(titles(1, version: "6.3") == ["General"])
        #expect(titles(2) == ["General"])
        #expect(titles(86_400).isEmpty)
    }

    @Test
    func aWithdrawalOrInvalidSectionClearsAnEarlierNotice() throws {
        let feed = try decodeFeed()
        let empty = try JSONDecoder().decode(
            MHAnnouncementFeed.self,
            from: Data(#"{"schemaVersion":1,"defaultLanguage":"en","items":[]}"#.utf8)
        )
        let replacements: [MHRemoteConfigSection<MHAnnouncementFeed>] = [
            .missing, .invalid(CocoaError(.coderReadCorrupt)), .value(empty)
        ]
        for replacement in replacements {
            let store = RemoteAnnouncementStore()
            let original = MHRemoteConfigResponse(value: MHRemoteConfigSection.value(feed), fetchedAt: fetchedAt)
            store.receive(original)
            let newer = fetchedAt.addingTimeInterval(1)
            store.receive(.init(value: replacement, fetchedAt: newer))
            let visible = store.visibleAnnouncements(
                installedVersion: nil, at: newer, appLanguage: "en", preferredLanguages: ["en"]
            )
            #expect(visible.isEmpty)
        }
    }

    @Test(arguments: [("es", "Plan mensual en México"), ("ja", "月額プラン")])
    func appLanguagePreservesThePreferredRegionalTranslation(appLanguage: String, expected: String) throws {
        let store = RemoteAnnouncementStore()
        store.receive(.init(value: .value(try decodeFeed()), fetchedAt: fetchedAt))
        let notices = store.visibleAnnouncements(
            installedVersion: MHAppVersion("6.4"),
            at: fetchedAt.addingTimeInterval(1),
            appLanguage: appLanguage,
            preferredLanguages: ["en-GB", "es-MX"]
        )
        #expect(notices.first?.title == expected)
    }

    private func decodeFeed() throws -> MHAnnouncementFeed {
        let json = """
        {"schemaVersion":1,"defaultLanguage":"en","items":[
          {"id":"plan","startsAt":1001,"endsAt":1002,"minimumVersion":"6.4",
           "localizations":{"en":{"title":"Monthly plan","body":"Plan update"},
                            "es":{"title":"Plan mensual","body":"Aviso"},
                            "es-MX":{"title":"Plan mensual en México","body":"Aviso"},
                            "ja":{"title":"月額プラン","body":"プランのお知らせ"}}},
          {"id":"general","localizations":{"en":{"title":"General","body":"General notice"}}}
        ]}
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(MHAnnouncementFeed.self, from: Data(json.utf8))
    }
}
