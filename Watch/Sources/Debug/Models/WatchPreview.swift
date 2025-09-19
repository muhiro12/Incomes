import SwiftData
import SwiftUI

struct WatchPreview<Content: View>: View {
    @State private var isReady = false

    private let content: () -> Content
    private let previewModelContainer: ModelContainer

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.previewModelContainer = try! .init(
            for: Item.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
    }

    var body: some View {
        Group {
            if isReady {
                content()
            } else {
                ProgressView()
                    .task {
                        do {
                            try ItemService.seedTutorialDataIfNeeded(
                                context: previewModelContainer.mainContext
                            )
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                        isReady = true
                    }
            }
        }
        .modelContainer(previewModelContainer)
    }
}
