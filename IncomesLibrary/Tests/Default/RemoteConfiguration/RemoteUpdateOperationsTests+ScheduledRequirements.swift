import Foundation
import IncomesLibrary
import MHPlatformCore
import Testing

extension RemoteUpdateOperationsTests {
    @Test
    func unpublishedFuturePlanDoesNotWeakenTheActiveMinimum() async throws {
        let fixture = try makeFixture(
            requirementOffset: .zero,
            scheduledRequirements: [try makePlan(version: "7.0", start: 60)],
            publishedVersion: "6.1"
        )
        try await fixture.operations.prepare()
        await expectBlocked(fixture.operations, error: .updateRequired)
        #expect(fixture.operations.decision == .updateRequired)
    }

    @Test
    func scheduledPlanActivatesAndEndsBeforeOfflineMutations() async throws {
        let fixture = try makeFixture(
            requirementOffset: .zero,
            minimumVersion: "5.0",
            scheduledRequirements: [try makePlan(version: "6.1", start: 60, end: 120)]
        )
        try await fixture.operations.prepare()
        #expect(fixture.operations.decision == .notRequired)
        await fixture.provider.goOffline()
        fixture.clock.advance(by: 60)
        await expectBlocked(fixture.operations, error: .updateRequired)
        fixture.clock.advance(by: 60)
        await expectBlocked(fixture.operations, error: .updateRequired)
        fixture.clock.advance(by: 1)
        var didMutate = false
        try await fixture.operations.performMutation {
            didMutate = true
        }
        #expect(didMutate)
        #expect(fixture.operations.decision == .notRequired)
        #expect(await fixture.provider.fetchCount == 1)
    }

    @Test
    func headlessEntryRestoresAnActivatedPlanBeforeMutation() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let store = MHRemoteUpdateStore(fileURL: directory.appendingPathComponent("snapshot.json"))
        let plans = [try makePlan(version: "6.1", start: 60)]
        let firstLaunch = try makeFixture(
            requirementOffset: .zero,
            minimumVersion: "5.0",
            scheduledRequirements: plans,
            store: store
        )
        try await firstLaunch.operations.prepare()
        let nextLaunch = try makeFixture(
            requirementOffset: .zero,
            minimumVersion: "5.0",
            scheduledRequirements: plans,
            store: store
        )
        nextLaunch.clock.advance(by: 60)
        await nextLaunch.provider.goOffline()
        await expectBlocked(nextLaunch.operations, error: .updateRequired)
        #expect(nextLaunch.operations.decision == .updateRequired)
        #expect(nextLaunch.operations.evaluation?.reason == .updateRequired)
        #expect(nextLaunch.operations.evaluation?.revision == 1)
        #expect(nextLaunch.operations.evaluation?.policyFreshness == .fresh)
        #expect(nextLaunch.operations.evaluation?.publicationFreshness == .fresh)
        #expect(await nextLaunch.provider.fetchCount == 0)
    }

    @Test(arguments: [false, true])
    func updateSectionControlsMutationsDespiteUnrelatedPayload(invalidPlan: Bool) async throws {
        let url = try #require(Bundle.module.url(
            forResource: "incomes",
            withExtension: "json",
            subdirectory: "Fixtures/RemoteConfiguration"
        ))
        var document = try #require(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        document["bundleIdentifier"] = "test.incomes.remote-update"
        var features = try #require(document["features"] as? [String: Any])
        features["futureFeature"] = false
        var update = try #require(features["remoteUpdate"] as? [String: Any])
        if invalidPlan {
            update["scheduledRequirements"] = NSNull()
        }
        features["remoteUpdate"] = update
        document["features"] = features
        let fixture = try makeFixture(configurationData: JSONSerialization.data(withJSONObject: document))
        let preparation = try await fixture.operations.prepare()
        if invalidPlan {
            #expect(preparation?.refreshError != nil)
            await expectBlocked(fixture.operations, error: .policyUnavailable)
            #expect(fixture.operations.decision == .unavailable)
        } else {
            #expect(preparation?.refreshError == nil)
            var didMutate = false
            try await fixture.operations.performMutation {
                didMutate = true
            }
            #expect(didMutate)
            #expect(fixture.operations.decision == .notRequired)
        }
    }
}
