import SwiftUI

struct SuggestionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title) {
            Haptic.selectionChanged.impact()
            action()
        }
        .incomesSecondaryControlStyle()
        .controlSize(.small)
    }
}
