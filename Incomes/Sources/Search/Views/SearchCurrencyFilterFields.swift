import SwiftUI

struct SearchCurrencyFilterFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat

    var body: some View {
        HStack(spacing: controlSpacing) {
            TextField("Min", text: $minValue)
                .keyboardType(.numbersAndPunctuation)
            Text("~")
            TextField("Max", text: $maxValue)
                .keyboardType(.numbersAndPunctuation)
        }
    }
}
