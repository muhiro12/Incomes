//
//  ConfigurationService.swift
//
//
//  Created by Hiromu Nakano on 2024/06/06.
//

import Foundation

@Observable
final class ConfigurationService {
    private(set) var configuration: Configuration?

    private let decoder = JSONDecoder()

    func load() async throws {
        guard let configurationURL = URL(
            string: "https://raw.githubusercontent.com/muhiro12/Incomes/main/.config.json"
        ) else {
            throw URLError(.badURL)
        }
        let data = try await URLSession.shared.data(
            from: configurationURL
        ).0
        configuration = try decoder.decode(Configuration.self, from: data)
    }

    func isUpdateRequired() -> Bool {
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let required = configuration?.requiredVersion,
              Bundle.main.bundleIdentifier?.contains("playgrounds") == false else {
            return false
        }
        return VersionComparator.isUpdateRequired(current: current, required: required)
    }
}
