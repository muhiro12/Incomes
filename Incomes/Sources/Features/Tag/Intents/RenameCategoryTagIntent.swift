import AppIntents
import SwiftData

struct RenameCategoryTagIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Rename Category Tag", table: "AppIntents")
    static let isDiscoverable = false

    @Parameter(title: "Tag")
    private var tag: TagEntity
    @Parameter(title: "New Name")
    private var newName: String

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() async throws -> some ReturnsValue<TagEntity> {
        try await IncomesMutationWorkflow.checkUpdateRequirement()
        let model = try tag.model(in: modelContainer.mainContext)
        try LedgerMutationAccess.requireEditing([.default])
        let renamed = try TagRenameOperations.renameCategoryAndSave(
            context: modelContainer.mainContext,
            tag: model,
            to: newName
        )
        return .result(value: try TagEntity.make(from: renamed))
    }
}
