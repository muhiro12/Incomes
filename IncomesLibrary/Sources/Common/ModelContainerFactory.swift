import SwiftData

public enum ModelContainerFactory {
    public static func shared() throws -> ModelContainer {
        try ModelContainer(
            for: Item.self,
            configurations: .init(
                url: Database.url
            )
        )
    }

    public static func sharedContext() throws -> ModelContext {
        .init(try shared())
    }
}
