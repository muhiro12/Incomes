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
    private(set) var remoteConfiguration: RemoteConfiguration?

    private let decoder = JSONDecoder()
    private let logger: MHLogger

    init(logger: MHLogger) {
        self.logger = logger
    }

    func load() async throws {
        guard let remoteConfigurationURL = URL(
            string: "https://raw.githubusercontent.com/muhiro12/Incomes/main/.config.json"
        ) else {
            logger.error(
                "remote_configuration.request_failed",
                metadata: IncomesLogging.metadata(
                    ("phase", "url_build"),
                    ("failure_reason", "bad_url")
                )
            )
            throw URLError(.badURL)
        }
        logger.info("remote_configuration.request_started")
        do {
            let data = try await URLSession.shared.data(
                from: remoteConfigurationURL
            ).0
            let remoteConfiguration = try decoder.decode(RemoteConfiguration.self, from: data)
            self.remoteConfiguration = remoteConfiguration
            logger.notice(
                "remote_configuration.loaded",
                metadata: IncomesLogging.metadata(
                    ("required_version", remoteConfiguration.requiredVersion),
                    ("update_required", IncomesLogging.bool(isUpdateRequired()))
                )
            )
        } catch {
            let requestMetadata = IncomesLogging.metadata(
                ("phase", "fetch_or_decode")
            )
            let failureMetadata = requestMetadata.merging(
                IncomesLogging.errorMetadata(error)
            ) { current, _ in
                current
            }
            logger.error(
                "remote_configuration.request_failed",
                metadata: failureMetadata
            )
            throw error
        }
    }

    func isUpdateRequired() -> Bool {
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let required = remoteConfiguration?.requiredVersion,
              Bundle.main.bundleIdentifier?.contains("playgrounds") == false else {
            return false
        }
        return RemoteConfigurationOperations.isUpdateRequired(
            currentVersion: current,
            requiredVersion: required
        )
    }
}
