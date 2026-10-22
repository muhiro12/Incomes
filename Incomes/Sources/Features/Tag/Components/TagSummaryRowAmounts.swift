import SwiftUI

struct TagSummaryRowAmounts: View {
    let incomeText: String
    let outgoText: String
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment) {
            Text(incomeText)
            Text(outgoText)
        }
        .font(.subheadline)
        .lineLimit(1)
        .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
        .foregroundStyle(.secondary)
        .monospacedDigit()
    }
}
