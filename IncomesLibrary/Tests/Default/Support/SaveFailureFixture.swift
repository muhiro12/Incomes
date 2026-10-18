import Foundation
@testable import IncomesLibrary
import SwiftData

/// Disk-backed contexts for a genuine save refusal and a writable retry.
@MainActor
final class SaveFailureFixture {
    let url: URL
    let container: ModelContainer
    let context: ModelContext
    private(set) var saveAttempts = 0
    private var observer: (any NSObjectProtocol)?

    init(url: URL) throws {
        self.url = url
        container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        context = .init(container)
        context.autosaveEnabled = false
    }

    static func withStore(_ body: (SaveFailureFixture) throws -> Void) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        try autoreleasepool {
            let fixture = try SaveFailureFixture(url: directory.appendingPathComponent("Incomes.sqlite"))
            defer {
                fixture.stopObserving()
            }
            try body(fixture)
        }
    }

    func readOnlyContext() throws -> ModelContext {
        .init(try ModelContainerFactory.readOnly(at: url))
    }

    func reopenedContext() throws -> ModelContext {
        .init(try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none)))
    }

    func observeSaves(in context: ModelContext) {
        observer = NotificationCenter.default.addObserver(
            forName: ModelContext.willSave,
            object: context,
            queue: nil
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.saveAttempts += 1
            }
        }
    }

    func stopObserving() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
}
