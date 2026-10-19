import Foundation
import IncomesLibrary
import MHPlatformCore
import Synchronization
import Testing

@MainActor
struct RemoteUpdateOperationsTests {
    @Test
    func systemSurfacesReceiveLocalizedRecoveryGuidance() {
        var resource = RemoteUpdateError.policyUnavailable.localizedStringResource
        resource.locale = .init(identifier: "ja")
        #expect(String(localized: resource) == "アップデートの要否を確認できませんでした。インターネットに接続して、もう一度お試しください。")
    }

    @Test
    func disabledEnvironmentPermitsLocalMutationsWithoutPreparation() async throws {
        let operations = RemoteUpdateOperations()
        var mutationCount = 0
        let preparation = try await operations.prepare()
        try await operations.performMutation {
            mutationCount += 1
        }
        #expect(operations.isEnabled == false)
        #expect(preparation == nil)
        #expect(mutationCount == 1)
    }

    @Test
    func invalidConfigurationKeepsMutationGateClosed() async {
        let operations = RemoteUpdateOperations(configurationError: TestError.invalidConfiguration)
        await #expect(throws: TestError.invalidConfiguration) {
            try await operations.prepare()
        }
        await expectBlocked(operations, error: .policyUnavailable)
        #expect(operations.isEnabled)
        #expect(operations.decision == .unavailable)
    }

    @Test
    func confirmedCancellationAllowsMutationAndSuccessEffects() async throws {
        let fixture = try makeFixture()
        try await fixture.operations.prepare()
        var events: [String] = []
        try await fixture.operations.performMutation {
            events.append("mutation")
            events.append("success")
        }
        #expect(fixture.operations.decision == .notRequired)
        #expect(events == ["mutation", "success"])
    }

    @Test
    func publishedActiveRequirementStopsMutationAndSuccessEffects() async throws {
        let fixture = try makeFixture(requirementOffset: .zero)
        try await fixture.operations.prepare()
        await expectBlocked(fixture.operations, error: .updateRequired)
        #expect(fixture.operations.decision == .updateRequired)
    }

    @Test
    func unpublishedActiveRequirementDoesNotAuthorizeMutation() async throws {
        let fixture = try makeFixture(requirementOffset: .zero, publishedVersion: nil)
        try await fixture.operations.prepare()
        await expectBlocked(fixture.operations, error: .policyUnavailable)
        #expect(fixture.operations.decision == .unavailable)
    }

    @Test
    func retainedFutureRequirementIsReevaluatedBeforeMutation() async throws {
        let fixture = try makeFixture(requirementOffset: 10)
        try await fixture.operations.prepare()
        #expect(fixture.operations.decision == .notRequired)
        fixture.clock.advance(by: 11)
        await expectBlocked(fixture.operations, error: .updateRequired)
        #expect(fixture.operations.decision == .updateRequired)
        #expect(await fixture.provider.fetchCount == 1)
    }

    @Test
    func failedRefreshRetainsStillValidPermission() async throws {
        let fixture = try makeFixture()
        try await fixture.operations.prepare()
        await fixture.provider.goOffline()
        let preparation = try await fixture.operations.prepare()
        #expect(preparation?.refreshError != nil)
        var didMutate = false
        try await fixture.operations.performMutation {
            didMutate = true
        }
        #expect(didMutate)
        #expect(fixture.operations.decision == .notRequired)
    }

    @Test
    func headlessEntryRestoresRetainedPermissionBeforeChecking() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let store = MHRemoteUpdateStore(fileURL: directory.appendingPathComponent("snapshot.json"))
        let firstLaunch = try makeFixture(store: store)
        try await firstLaunch.operations.prepare()

        let nextLaunch = try makeFixture(store: store)
        await nextLaunch.provider.goOffline()
        var didMutate = false
        try await nextLaunch.operations.performMutation {
            didMutate = true
        }
        #expect(didMutate)
        #expect(nextLaunch.operations.decision == .notRequired)
    }

    @Test
    func expiredEvidenceCannotAuthorizeOfflineMutation() async throws {
        let fixture = try makeFixture()
        try await fixture.operations.prepare()
        fixture.clock.advance(by: 601)
        await fixture.provider.goOffline()
        await expectBlocked(fixture.operations, error: .policyUnavailable)
        #expect(fixture.operations.decision == .unavailable)
    }

    @Test
    func unchangedOnlinePolicyNeedsNoPublisherRenewalAfterThirtyDays() async throws {
        let fixture = try makeFixture()
        try await fixture.operations.prepare()
        fixture.clock.advance(by: 31 * 86_400)
        var didMutate = false
        try await fixture.operations.performMutation {
            didMutate = true
        }
        #expect(didMutate)
        #expect(fixture.operations.decision == .notRequired)
        #expect(await fixture.provider.fetchCount == 2)
    }

    @Test
    func reusingAnOldResponseCannotRenewMutationPermission() async throws {
        let fixture = try makeFixture()
        let originalObservation = fixture.clock.now()
        try await fixture.operations.prepare()
        await fixture.provider.reuseObservation(from: originalObservation)
        fixture.clock.advance(by: FixtureValues.validity + 1)
        await expectBlocked(fixture.operations, error: .policyUnavailable)
        #expect(fixture.operations.decision == .unavailable)
        #expect(await fixture.provider.fetchCount == 2)
    }

    @Test
    func initialAppConfigurationPreservesTheExistingMinimumVersion() throws {
        let url = try #require(Bundle.module.url(
            forResource: "incomes",
            withExtension: "json",
            subdirectory: "Fixtures/RemoteConfiguration"
        ))
        let schedule = try MHRemoteUpdateSchedule.decode(Data(contentsOf: url))
        #expect(schedule.bundleIdentifier == "com.muhiro12.Incomes")
        #expect(schedule.revision == 1)
        #expect(schedule.requirement?.minimumVersion == MHAppVersion("5.0"))
        #expect(schedule.requirement?.effectiveAt == ISO8601DateFormatter().date(from: "2026-10-19T00:00:00Z"))
        #expect(schedule.requirement?.endsAt == nil)
    }

    @Test
    func cancellationSkipsMutationAndSuccessEffects() async {
        let operations = RemoteUpdateOperations()
        var didMutate = false
        let task = Task {
            try await operations.performMutation {
                didMutate = true
            }
        }
        task.cancel()
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
        #expect(didMutate == false)
    }

    @Test
    func mutationErrorsRemainDomainErrors() async throws {
        let fixture = try makeFixture()
        try await fixture.operations.prepare()
        await #expect(throws: TestError.mutationFailed) {
            try await fixture.operations.performMutation {
                throw TestError.mutationFailed
            }
        }
        #expect(fixture.operations.decision == .notRequired)
    }
}

private extension RemoteUpdateOperationsTests {
    enum FixtureValues {
        static let initialTimestamp: TimeInterval = 1_000
        static let validity: TimeInterval = 600
    }

    enum TestError: Error {
        case invalidConfiguration
        case offline
        case mutationFailed
    }

    final class Clock: Sendable {
        private let value = Mutex(Date(timeIntervalSinceReferenceDate: FixtureValues.initialTimestamp))

        func now() -> Date {
            value.withLock { $0 }
        }

        func advance(by seconds: TimeInterval) {
            value.withLock { current in
                current = current.addingTimeInterval(seconds)
            }
        }
    }

    actor Provider {
        let schedule: MHRemoteUpdateSchedule
        private(set) var fetchCount = 0
        private var isOffline = false
        private var reusedObservation: Date?

        init(schedule: MHRemoteUpdateSchedule) {
            self.schedule = schedule
        }

        func fetch(observedAt date: Date) throws -> MHRemoteConfigResponse<MHRemoteUpdateSchedule> {
            fetchCount += 1
            if isOffline {
                throw TestError.offline
            }
            return .init(value: schedule, fetchedAt: reusedObservation ?? date)
        }

        func goOffline() {
            isOffline = true
        }

        func reuseObservation(from date: Date) {
            reusedObservation = date
        }
    }

    struct Fixture {
        let operations: RemoteUpdateOperations
        let provider: Provider
        let clock: Clock
    }

    func makeFixture(
        requirementOffset: TimeInterval? = nil,
        publishedVersion: String? = "6.1",
        store: MHRemoteUpdateStore? = nil
    ) throws -> Fixture {
        let clock = Clock()
        let minimumVersion = try #require(MHAppVersion("6.1"))
        let requirement = requirementOffset.map { offset in
            MHRemoteUpdateSchedule.Requirement(
                minimumVersion: minimumVersion,
                effectiveAt: clock.now().addingTimeInterval(offset)
            )
        }
        let provider = Provider(schedule: try .init(
            bundleIdentifier: "test.incomes.remote-update",
            revision: 1,
            requirement: requirement
        ))
        let controller = try MHRemoteUpdateController(
            bundleIdentifier: "test.incomes.remote-update",
            storefront: "jp",
            policyLifetime: FixtureValues.validity,
            publicationLifetime: FixtureValues.validity,
            store: store,
            currentVersion: { "6.0" },
            now: clock.now,
            fetchSchedule: {
                try await provider.fetch(observedAt: clock.now())
            },
            publicVersion: {
                publishedVersion.flatMap(MHAppVersion.init)
            }
        )
        return .init(operations: .init(controller: controller), provider: provider, clock: clock)
    }

    func expectBlocked(_ operations: RemoteUpdateOperations, error: RemoteUpdateError) async {
        var events: [String] = []
        await #expect(throws: error) {
            try await operations.performMutation {
                events.append("mutation")
                events.append("success")
            }
        }
        #expect(events.isEmpty)
    }
}
