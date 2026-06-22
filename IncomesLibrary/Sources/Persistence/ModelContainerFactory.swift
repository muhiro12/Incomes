import SwiftData

/// Factory helpers to create shared `ModelContainer`/`ModelContext` for the app group.
public enum ModelContainerFactory {
    /// Creates a `ModelContainer` persisted at the library's `Database.url`.
    public static func shared() throws -> ModelContainer {
        try ModelContainer(
            for: Item.self,
            configurations: .init(
                url: Database.url
            )
        )
    }

    /// Creates a `ModelContext` from the shared container.
    public static func sharedContext() throws -> ModelContext {
        .init(try shared())
    }
}
