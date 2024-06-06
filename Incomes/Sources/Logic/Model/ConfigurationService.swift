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
        let data = try await URLSession.shared.data(
            from: .init(
                string: "https://raw.githubusercontent.com/muhiro12/Incomes/main/.config"
            )!
        ).0
        configuration = try decoder.decode(Configuration.self, from: data)
    }

    func ensureVersion() -> Bool {
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let required = configuration?.requiredVersion else {
            return false
        }
        return current.compare(required, options: .numeric) == .orderedAscending
    }
}
