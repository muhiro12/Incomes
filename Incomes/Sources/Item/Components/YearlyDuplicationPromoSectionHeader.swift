import SwiftUI

struct YearlyDuplicationPromoSectionHeader: View {
    let dismiss: () -> Void

    var body: some View {
        HStack {
            Text("Yearly duplication")
            Spacer()
            Button(role: .cancel) {
                dismiss()
            } label: {
                CloseButtonLabel()
            }
            .incomesDismissControlStyle()
            .accessibilityLabel(Text("Close"))
            .accessibilityHint(Text("Dismisses the yearly duplication suggestion."))
        }
    }
}
