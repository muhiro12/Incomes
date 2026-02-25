@testable import IncomesLibrary
import Testing

struct IncomesRouteURLDefaultsTests {
    @Test
    func universal_link_associated_domain_matches_host() {
        #expect(
            IncomesRouteURLDefaults.universalLinkAssociatedDomain ==
                "applinks:\(IncomesRouteURLDefaults.universalLinkHost)"
        )
    }
}
