import SwiftUI

struct ItemFormAmountValidationMessage: View {
    var body: some View {
        Label {
            Text("Invalid amount. Enter a number.")
        } icon: {
            Image(systemName: "exclamationmark.circle.fill")
                .accessibilityHidden(true)
        }
        .font(.footnote)
        .foregroundStyle(.red)
    }
}
