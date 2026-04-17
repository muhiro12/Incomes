import MHPlatform
import SwiftUI

struct DebugDiagnosticsView: View {
    @Environment(MHLoggingBootstrap.self)
    private var logging

    var body: some View {
        MHLogConsoleView(logging: logging)
            .navigationTitle("Diagnostics Console")
            .toolbar {
                ToolbarItem {
                    CloseButton()
                }
            }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        DebugDiagnosticsView()
    }
}
