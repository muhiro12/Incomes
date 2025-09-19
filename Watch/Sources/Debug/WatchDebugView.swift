import IncomesLibrary
import SwiftData
import SwiftUI

struct WatchDebugView {
    @Environment(\.modelContext)
    private var context

    @State private var hasDebugData = false
    @State private var isSeeding = false
    @State private var isDeleting = false
}

extension WatchDebugView: View {
    var body: some View {
        List {
            Section {
                Button {
                    seedTutorialData()
                } label: {
                    if isSeeding {
                        ProgressView()
                    } else {
                        Text("Seed Tutorial Data")
                    }
                }
                .disabled(isSeeding)
            } footer: {
                Text("Creates a few sample items tagged as Debug when the store is empty.")
            }

            if hasDebugData {
                Section {
                    Button(role: .destructive) {
                        deleteDebugData()
                    } label: {
                        if isDeleting {
                            ProgressView()
                        } else {
                            Text("Delete tutorial/debug data")
                        }
                    }
                    .disabled(isDeleting)
                } footer: {
                    Text("Removes items tagged as Debug and their tags.")
                }
            }
        }
        .navigationTitle("Debug")
        .task {
            refreshDebugPresence()
        }
    }
}

private extension WatchDebugView {
    func refreshDebugPresence() {
        do {
            hasDebugData = try ItemService.hasDebugData(context: context)
        } catch {
            assertionFailure(error.localizedDescription)
            hasDebugData = false
        }
    }

    func seedTutorialData() {
        isSeeding = true
        defer {
            isSeeding = false
        }
        do {
            try ItemService.seedTutorialDataIfNeeded(context: context)
            refreshDebugPresence()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func deleteDebugData() {
        isDeleting = true
        defer {
            isDeleting = false
        }
        do {
            try ItemService.deleteDebugData(context: context)
            refreshDebugPresence()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#Preview {
    WatchPreview {
        NavigationStack {
            WatchDebugView()
        }
    }
}
