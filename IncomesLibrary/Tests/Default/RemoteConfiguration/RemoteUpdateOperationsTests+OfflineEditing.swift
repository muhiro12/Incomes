import Foundation
import IncomesLibrary
import MHPlatformCore
import Testing

extension RemoteUpdateOperationsTests {
    @Test(arguments: [false, true])
    func firstUseOfflineEditingRequiresAnExplicitException(isAllowed: Bool) async throws {
        let fixture = try makeFixture { isAllowed }
        await fixture.provider.goOffline()
        if isAllowed {
            var events: [String] = []
            try await fixture.operations.performMutation {
                events = ["mutation", "success"]
            }
            #expect(events == ["mutation", "success"])
        } else {
            await expectBlocked(fixture.operations, error: .policyUnavailable)
        }
        #expect(fixture.operations.decision == .unavailable)
    }

    @Test
    func theExceptionAllowsExpiredEvidenceWithoutPretendingThePolicyWasVerified() async throws {
        let fixture = try makeFixture { true }
        try await fixture.operations.prepare()
        fixture.clock.advance(by: FixtureValues.validity + 1)
        await fixture.provider.goOffline()
        var didMutate = false
        try await fixture.operations.performMutation {
            didMutate = true
        }
        #expect(didMutate)
        #expect(fixture.operations.decision == .unavailable)
        #expect(fixture.operations.evaluation?.reason == .policyExpired)
        #expect(await fixture.provider.fetchCount == 1)
    }

    @Test
    func theExceptionCannotBypassAConfirmedRequiredUpdate() async throws {
        let fixture = try makeFixture(requirementOffset: .zero) { true }
        try await fixture.operations.prepare()
        await fixture.provider.goOffline()
        await expectBlocked(fixture.operations, error: .updateRequired)
        #expect(fixture.operations.decision == .updateRequired)
    }

    @Test
    func anExpiredRequiredPolicyCanBeBypassedAndKeepsItsUnverifiedStatus() async throws {
        let fixture = try makeFixture(requirementOffset: .zero) { true }
        try await fixture.operations.prepare()
        await expectBlocked(fixture.operations, error: .updateRequired)
        fixture.clock.advance(by: FixtureValues.validity + 1)
        await fixture.provider.goOffline()
        var didMutate = false
        try await fixture.operations.performMutation {
            didMutate = true
        }
        #expect(didMutate)
        #expect(fixture.operations.decision == .unavailable)
        #expect(fixture.operations.evaluation?.reason == .policyExpired)
    }

    @Test
    func aKnownScheduledUpdateStillActivatesDuringOfflineEditing() async throws {
        let fixture = try makeFixture(
            requirementOffset: .zero,
            minimumVersion: "5.0",
            scheduledRequirements: [try makePlan(version: "6.1", start: 60)]
        ) { true }
        try await fixture.operations.prepare()
        await fixture.provider.goOffline()
        fixture.clock.advance(by: 60)
        await expectBlocked(fixture.operations, error: .updateRequired)
    }

    @Test
    func changingTheExceptionTakesEffectBeforeTheNextMutation() async throws {
        var isAllowed = false
        let fixture = try makeFixture { isAllowed }
        await fixture.provider.goOffline()
        await expectBlocked(fixture.operations, error: .policyUnavailable)
        isAllowed = true
        var mutationCount = 0
        try await fixture.operations.performMutation {
            mutationCount += 1
        }
        isAllowed = false
        await expectBlocked(fixture.operations, error: .policyUnavailable)
        #expect(mutationCount == 1)
    }

    @Test
    func savedPermissionIsOffByDefaultAndSurvivesRelaunch() async throws {
        let suiteName = "RemoteUpdateOfflineEditingTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }
        let descriptor = MHPreferenceDescriptors().allowsUnverifiedEditing
        let preferences = MHPreferenceStore(userDefaults: defaults)
        #expect(!preferences.bool(for: descriptor))
        #expect(descriptor.defaultSelection == .standard)
        preferences.set(true, for: descriptor)
        let nextLaunch = try makeFixture {
            MHPreferenceStore(userDefaults: defaults).bool(for: descriptor)
        }
        await nextLaunch.provider.goOffline()
        var didMutate = false
        try await nextLaunch.operations.performMutation {
            didMutate = true
        }
        #expect(didMutate)
        #expect(nextLaunch.operations.decision == .unavailable)
    }

    @Test
    func cancellationStillPreventsOfflineEditingWithTheException() async throws {
        let fixture = try makeFixture { true }
        var didMutate = false
        let task = Task {
            try await fixture.operations.performMutation {
                didMutate = true
            }
        }
        task.cancel()
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
        #expect(!didMutate)
    }
}
