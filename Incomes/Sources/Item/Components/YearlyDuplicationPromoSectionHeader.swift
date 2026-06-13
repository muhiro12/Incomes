import SwiftUI

struct YearlyDuplicationPromoSectionHeader: View {
    let dismiss: () -> Void

    var body: some View {
        HStack {
            Text("Yearly duplication")
            Spacer()
            Button {
                dismiss()
            } label: {
                Label {
                    Text("Close")
                } icon: {
                    closeIcon
                }
                .labelStyle(.iconOnly)
            }
            .incomesDismissControlStyle()
            .accessibilityLabel(Text("Close"))
        }
    }

    @ViewBuilder private var closeIcon: some View {
        if #available(iOS 26.0, *) {
            Image(systemName: "xmark")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
    }
}
