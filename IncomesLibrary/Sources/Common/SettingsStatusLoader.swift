import Foundation
import SwiftData

public struct SettingsStatus {
    public let hasDuplicateTags: Bool
    public let hasDebugData: Bool

    public init(
        hasDuplicateTags: Bool,
        hasDebugData: Bool
    ) {
        self.hasDuplicateTags = hasDuplicateTags
        self.hasDebugData = hasDebugData
    }
}

public enum SettingsStatusLoader {
    public static func load(
        context: ModelContext
    ) throws -> SettingsStatus {
        let hasDuplicateTags = try TagService.hasDuplicates(context: context)
        let hasDebugData = try ItemService.hasDebugData(context: context)
        return .init(
            hasDuplicateTags: hasDuplicateTags,
            hasDebugData: hasDebugData
        )
    }
}
