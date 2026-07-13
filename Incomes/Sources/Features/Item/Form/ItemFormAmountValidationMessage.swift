import SwiftUI

struct ItemFormAmountValidationMessage: View {
    var body: some View {
        Label {
            Text("Enter a valid amount with up to 14 digits.")
        } icon: {
            Image(systemName: "exclamationmark.circle.fill")
                .accessibilityHidden(true)
        }
        .font(.footnote)
        .foregroundStyle(.red)
    }
}
