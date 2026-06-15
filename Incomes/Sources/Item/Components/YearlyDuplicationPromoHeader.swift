import SwiftUI

struct YearlyDuplicationPromoHeader: View {
    private enum Constants {
        static let textSpacing: CGFloat = 2
    }

    let sourceYear: Int
    let targetYear: Int
    let spacing: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            YearlyDuplicationPromoIcon()
            VStack(alignment: .leading, spacing: Constants.textSpacing) {
                Text("Duplicate Year")
                    .font(.headline)
                Text("Year: \(sourceYear) -> \(targetYear)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
