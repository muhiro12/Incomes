import Foundation
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

    @Test
    func entitlements_include_shared_associated_domain_setting() throws {
        let repositoryRootURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let entitlementsURL = repositoryRootURL
            .appendingPathComponent("Incomes/Configurations/Incomes.entitlements")
        let entitlementsContent = try String(contentsOf: entitlementsURL)

        #expect(
            entitlementsContent.contains(IncomesRouteURLDefaults.universalLinkAssociatedDomain)
        )
    }
}
