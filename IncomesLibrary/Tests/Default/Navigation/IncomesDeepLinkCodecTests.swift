import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesDeepLinkCodecTests {
    @Test
    func shared_codec_prefers_universal_links() {
        let url = IncomesDeepLinkCodec.shared.preferredURL(for: .settings)

        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/settings"
        )
    }

    @Test
    func shared_codec_parses_default_custom_scheme_urls() {
        let url = URL(string: "incomes://settings/subscription")

        let route = url.flatMap(IncomesDeepLinkCodec.shared.parse)

        #expect(route == .settingsSubscription)
    }

    @Test
    func shared_codec_parses_default_universal_link_urls() {
        let url = URL(string: "https://muhiro12.github.io/Incomes/month/2026-04")

        let route = url.flatMap(IncomesDeepLinkCodec.shared.parse)

        #expect(route == .month(year: 2_026, month: 4))
    }

    @Test
    func make_builds_preferred_url_with_custom_host_and_prefix() {
        let codec = IncomesDeepLinkCodec.make(
            host: "example.com",
            appPathPrefix: "Budget"
        )

        let url = codec.preferredURL(for: .month(year: 2_026, month: 3))

        #expect(
            url?.absoluteString == "https://example.com/Budget/month/2026-03"
        )
    }

    @Test
    func make_uses_custom_host_as_default_allowed_host() throws {
        let codec = IncomesDeepLinkCodec.make(
            host: "example.com",
            appPathPrefix: "Budget"
        )
        let url = try #require(codec.preferredURL(for: .settings))

        let route = codec.parse(url)

        #expect(url.absoluteString == "https://example.com/Budget/settings")
        #expect(route == .settings)
    }

    @Test
    func make_parses_universal_link_from_explicit_allowed_host() {
        let codec = IncomesDeepLinkCodec.make(
            host: "example.com",
            allowedUniversalLinkHosts: ["links.example.com"],
            appPathPrefix: "Budget"
        )
        let url = URL(string: "https://links.example.com/Budget/search?q=rent")

        let route = url.flatMap(codec.parse)

        #expect(route == .search(query: "rent"))
    }

    @Test
    func make_parses_custom_scheme_without_universal_link_host_match() {
        let codec = IncomesDeepLinkCodec.make(
            allowedUniversalLinkHosts: ["example.com"]
        )
        let url = URL(string: "incomes://yearly-duplication")

        let route = url.flatMap(codec.parse)

        #expect(route == .yearlyDuplication)
    }
}
