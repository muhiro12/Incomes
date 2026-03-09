//
//  RemoteConfigurationService.swift
//
//
//  Created by Hiromu Nakano on 2024/06/06.
//

import Foundation

@Observable
final class RemoteConfigurationService {
    private(set) var remoteConfiguration: RemoteConfiguration?

    private let decoder = JSONDecoder()

    func load() async throws {
        guard let remoteConfigurationURL = URL(
            string: "https://raw.githubusercontent.com/muhiro12/Incomes/main/.config.json"
        ) else {
            throw URLError(.badURL)
        }
        let data = try await URLSession.shared.data(
            from: remoteConfigurationURL
        ).0
        remoteConfiguration = try decoder.decode(RemoteConfiguration.self, from: data)
    }

    func isUpdateRequired() -> Bool {
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let required = remoteConfiguration?.requiredVersion,
              Bundle.main.bundleIdentifier?.contains("playgrounds") == false else {
            return false
        }
        return VersionComparator.isUpdateRequired(current: current, required: required)
    }
}
