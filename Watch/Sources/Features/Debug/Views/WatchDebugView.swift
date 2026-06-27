import MHPreferences
import MHPreferencesUI
import SwiftData
import SwiftUI

struct WatchDebugView {
    @Environment(\.modelContext)
    private var context

    @AppStorage(\.isDebugOn)
    private var isDebugOn

    @State private var hasDebugData = false
}

extension WatchDebugView: View {
    var body: some View {
        List {
            WatchDebugOptionSection(isDebugOn: $isDebugOn)
            WatchDebugNavigationSection()
            if hasDebugData {
                WatchDebugSampleDataSection(
                    deleteDebugData: deleteDebugData
                )
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

#Preview {
    WatchPreview {
        NavigationStack {
            WatchDebugView()
        }
    }
}
