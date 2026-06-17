import SwiftUI

struct CloseButton: View {
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        Button(role: .cancel) {
            dismiss()
        } label: {
            CloseButtonLabel()
        }
        .accessibilityLabel(Text("Close"))
        .accessibilityHint(Text("Dismisses the current screen."))
    }
}

#Preview {
    NavigationStack {
        List {
            CloseButton()
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}
