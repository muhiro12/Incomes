import UniformTypeIdentifiers

extension UTType {
    /// Incomes file type, declared in Info.plist.
    nonisolated static let incomesData = UTType(
        exportedAs: ItemExportOperations.fileTypeIdentifier,
        conformingTo: .json
    )
}
