import SwiftData
import SwiftUI

struct WatchDebugView {
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var hasDebugData = false
    @State private var isDeleting = false
}

extension WatchDebugView: View {
    var body: some View {
        List {
            Section {
                Toggle(isOn: $isDebugOn) {
                    Text("Debug option")
                }
            }
            Section {
                NavigationLink {
                    WatchItemListView()
                } label: {
                    Label("Items", systemImage: "list.bullet")
                }
                NavigationLink {
                    WatchTagListView()
                } label: {
                    Label("Tags", systemImage: "tag")
                }
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
