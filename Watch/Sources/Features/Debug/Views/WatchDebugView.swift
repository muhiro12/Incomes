import MHPreferences
import MHPreferencesUI
import SwiftData
import SwiftUI

struct WatchDebugView {
    @Environment(\.modelContext)
    private var context

    @State private var hasDebugData = false
}

extension WatchDebugView: View {
    var body: some View {
        List {
            WatchDebugNavigationSection()
            #if DEBUG
            if hasDebugData {
                WatchDebugSampleDataSection(
                    deleteDebugData: deleteDebugData
                )
            }
            #endif
        }
        .navigationTitle("Diagnostics")
        #if DEBUG
        .task {
            refreshDebugPresence()
        }
        #endif
    }
}

#if DEBUG
private extension WatchDebugView {
    func refreshDebugPresence() {
        do {
            hasDebugData = try SampleDataOperations.hasDebugData(context: context)
        } catch {
            assertionFailure(error.localizedDescription)
            hasDebugData = false
        }
    }

    func deleteDebugData() {
        do {
            try SampleDataOperations.deleteDebugData(context: context)
            refreshDebugPresence()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#endif

#Preview {
    WatchPreview {
        NavigationStack {
            WatchDebugView()
        }
    }
}
