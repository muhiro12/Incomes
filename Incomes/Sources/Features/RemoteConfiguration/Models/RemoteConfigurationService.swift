//
//  RemoteConfigurationService.swift
//
//
//  Created by Hiromu Nakano on 2024/06/06.
//

import Foundation
import MHPlatform

@Observable
final class RemoteConfigurationService {
    private(set) var isLoading = false

    let scheduledUpdates: RemoteUpdateOperations

    private let logger: MHLogger

    init(
        logger: MHLogger,
        scheduledUpdates: RemoteUpdateOperations = IncomesRemoteUpdateConfiguration.operations
    ) {
        self.logger = logger
        self.scheduledUpdates = scheduledUpdates
    }

    func load() async throws {
        guard scheduledUpdates.isEnabled, isLoading == false else {
            return
        }
        isLoading = true
        defer {
            isLoading = false
        }
        try await prepareScheduledUpdates()
    }

    private func prepareScheduledUpdates() async throws {
        do {
            let preparation = try await scheduledUpdates.prepare()
            logger.notice(
                "remote_update.prepared",
                metadata: IncomesLogging.metadata(
                    ("decision", String(describing: scheduledUpdates.decision))
                )
            )
            for error in [preparation?.restorationError, preparation?.refreshError].compactMap(\.self) {
                logger.error("remote_update.preparation_failed", metadata: IncomesLogging.errorMetadata(error))
            }
        } catch {
            logger.error("remote_update.preparation_failed", metadata: IncomesLogging.errorMetadata(error))
            throw error
        }
    }
}
