import SwiftUI

struct ItemFormAmountValidationMessage: View {
    let rejection: DecimalTextRejection

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "exclamationmark.circle.fill")
                .accessibilityHidden(true)
        }
        .font(.footnote)
        .foregroundStyle(.red)
    }

    private var message: LocalizedStringKey {
        switch rejection {
        case .notANumber:
            return "Invalid amount. Enter a number."
        case .unsupportedAmount:
            return "This amount is too large or too detailed to save exactly. Enter a shorter amount."
        }
    }
}
