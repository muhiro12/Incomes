import SwiftUI

/// Shown when stored data cannot be opened, so startup stays recoverable.
struct IncomesStartupRecoveryView: View {
    private static let descriptionSpacing: CGFloat = 8

    let phase: IncomesStartupFailurePhase
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                Text("Incomes can't open your data")
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
        } description: {
            VStack(spacing: Self.descriptionSpacing) {
                Text(explanation)
                Text("Nothing was deleted. Your records are still stored on this device.")
            }
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }

    private var explanation: LocalizedStringKey {
        switch phase {
        case .databaseMigration:
            return "Your existing data could not be moved to its new location."
        case .modelContainer:
            return "Your saved data could not be opened."
        }
    }
}

#Preview {
    IncomesStartupRecoveryView(phase: .databaseMigration) {
        // Preview only.
    }
}
