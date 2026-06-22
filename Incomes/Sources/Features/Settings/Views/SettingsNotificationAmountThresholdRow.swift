import MHDesign
import SwiftUI

struct SettingsNotificationAmountThresholdRow: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var thresholdAmount: Decimal

    var body: some View {
        ViewThatFits(in: .horizontal) {
            LabeledContent {
                thresholdAmountField
            } label: {
                Text("Notify for amounts over")
            }

            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text("Notify for amounts over")
                thresholdAmountField
            }
        }
    }
}

private extension SettingsNotificationAmountThresholdRow {
    var currencyCode: String {
        locale.currency?.identifier ?? ""
    }

    var thresholdAmountField: some View {
        TextField(
            "Amount",
            value: $thresholdAmount,
            format: .currency(code: currencyCode)
        )
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .frame(maxWidth: designMetrics.layout.readableContentWidth)
        .accessibilityLabel(Text("Notification amount threshold"))
    }
}
