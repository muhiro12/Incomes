import Foundation
@testable import IncomesLibrary
import MHPlatformCore
import Testing

struct IncomesPreferenceLifecycleTests {
    @Test
    func runSynchronously_migratesLegacyValuesAndCleansTouchedDomains() throws {
        let testContext = try makeTestContext()

        defer {
            testContext.legacyDefaults.removePersistentDomain(forName: testContext.legacySuiteName)
            testContext.currentDefaults.removePersistentDomain(forName: testContext.currentSuiteName)
        }

        seedPreferences(for: testContext)

        let outcome = IncomesPreferenceLifecycle.runSynchronously(
            descriptors: testContext.descriptors,
            migrationStateDescriptor: testContext.migrationStateDescriptor
        )

        assertPreferenceState(for: testContext)
        assertMigrationOutcome(
            outcome.migrationOutcome,
            expectedStepIDs: testContext.displayNameDescriptor.migrationSteps().map(\.id)
        )
        assertCleanupReports(outcome, for: testContext)
    }
}

private extension IncomesPreferenceLifecycleTests {
    struct TestContext {
        let legacySuiteName: String
        let currentSuiteName: String
        let legacyDefaults: UserDefaults
        let currentDefaults: UserDefaults
        let storageKeyPrefix: String
        let displayNameDescriptor: MHStringPreferenceDescriptor
        let notificationsDescriptor: MHBoolPreferenceDescriptor
        let migrationStateDescriptor: MHPreferenceMigrationStateDescriptor
        let descriptors: [any MHStorageDescriptorProtocol]
    }

    enum TestError: Error {
        case userDefaultsCreationFailed
    }

    func makeTestContext() throws -> TestContext {
        let legacySuiteName = "IncomesPreferenceLifecycleTests.legacy.\(UUID().uuidString)"
        let currentSuiteName = "IncomesPreferenceLifecycleTests.current.\(UUID().uuidString)"
        let legacyDefaults = try makeUserDefaults(suiteName: legacySuiteName)
        let currentDefaults = try makeUserDefaults(suiteName: currentSuiteName)
        let storageKeyPrefix = "tests.preference-lifecycle"
        let displayNameDescriptor = MHStringPreferenceDescriptor(
            storageKey: "\(storageKeyPrefix).display-name",
            defaultSelection: .suite(currentSuiteName),
            legacySources: [
                .init(
                    storageKey: "\(storageKeyPrefix).legacy-display-name",
                    selection: .suite(legacySuiteName)
                )
            ]
        )
        let notificationsDescriptor = MHBoolPreferenceDescriptor(
            storageKey: "\(storageKeyPrefix).notifications",
            defaultSelection: .suite(currentSuiteName),
            default: true
        )
        let migrationStateDescriptor = MHPreferenceMigrationStateDescriptor(
            storageKey: "\(storageKeyPrefix).migration-state",
            defaultSelection: .suite(currentSuiteName)
        )

        return .init(
            legacySuiteName: legacySuiteName,
            currentSuiteName: currentSuiteName,
            legacyDefaults: legacyDefaults,
            currentDefaults: currentDefaults,
            storageKeyPrefix: storageKeyPrefix,
            displayNameDescriptor: displayNameDescriptor,
            notificationsDescriptor: notificationsDescriptor,
            migrationStateDescriptor: migrationStateDescriptor,
            descriptors: [
                displayNameDescriptor,
                notificationsDescriptor
            ]
        )
    }

    func makeUserDefaults(
        suiteName: String
    ) throws -> UserDefaults {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw TestError.userDefaultsCreationFailed
        }

        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }

    func seedPreferences(
        for testContext: TestContext
    ) {
        testContext.legacyDefaults.set(
            "Taylor",
            forKey: "\(testContext.storageKeyPrefix).legacy-display-name"
        )
        testContext.legacyDefaults.set(
            "stale",
            forKey: "\(testContext.storageKeyPrefix).legacy-unknown"
        )
        testContext.currentDefaults.set(
            false,
            forKey: testContext.notificationsDescriptor.storageKey
        )
        testContext.currentDefaults.set(
            "stale",
            forKey: "\(testContext.storageKeyPrefix).current-unknown"
        )
    }

    func assertPreferenceState(
        for testContext: TestContext
    ) {
        #expect(
            testContext.legacyDefaults.object(
                forKey: "\(testContext.storageKeyPrefix).legacy-display-name"
            ) == nil
        )
        #expect(
            testContext.legacyDefaults.object(
                forKey: "\(testContext.storageKeyPrefix).legacy-unknown"
            ) == nil
        )
        #expect(
            testContext.currentDefaults.string(
                forKey: testContext.displayNameDescriptor.storageKey
            ) == "Taylor"
        )
        #expect(
            testContext.currentDefaults.bool(
                forKey: testContext.notificationsDescriptor.storageKey
            ) == false
        )
        #expect(
            testContext.currentDefaults.object(
                forKey: "\(testContext.storageKeyPrefix).current-unknown"
            ) == nil
        )
        #expect(
            testContext.currentDefaults.object(
                forKey: testContext.migrationStateDescriptor.storageKey
            ) is Data
        )
    }

    func assertMigrationOutcome(
        _ outcome: MHPreferenceMigrationOutcome,
        expectedStepIDs: [String]
    ) {
        switch outcome {
        case let .succeeded(completedStepIDs, skippedStepIDs):
            #expect(completedStepIDs == expectedStepIDs)
            #expect(skippedStepIDs.isEmpty)
        case .failed:
            Issue.record("Preference lifecycle unexpectedly failed.")
        }
    }

    func makeCleanupReportsByDomain(
        from outcome: MHPreferenceLifecycleOutcome
    ) -> [String: [String]] {
        Dictionary(
            uniqueKeysWithValues: outcome.cleanupReports.map { report in
                (report.domainName, report.report.removedStorageKeys)
            }
        )
    }

    func assertCleanupReports(
        _ outcome: MHPreferenceLifecycleOutcome,
        for testContext: TestContext
    ) {
        let cleanupReportsByDomain = makeCleanupReportsByDomain(from: outcome)

        #expect(
            cleanupReportsByDomain[testContext.legacySuiteName] == ["\(testContext.storageKeyPrefix).legacy-unknown"]
        )
        #expect(
            cleanupReportsByDomain[testContext.currentSuiteName] == ["\(testContext.storageKeyPrefix).current-unknown"]
        )
    }
}
