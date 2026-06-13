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
        .foregroundStyle(.secondary)
        .monospacedDigit()
    }
}
