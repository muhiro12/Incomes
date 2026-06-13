import SwiftUI

struct YearlyDuplicationYearSelectionBar: View {
    @Binding var sourceYear: Int
    @Binding var targetYear: Int

    let sourceYears: [Int]
    let targetYears: [Int]
    let inlineSpacing: CGFloat
    let controlSpacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let surfaceCornerRadius: CGFloat

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: controlSpacing) {
            VStack(alignment: .leading, spacing: inlineSpacing) {
                Text("Year Range")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                YearlyDuplicationYearMenuGroup(
                    sourceYear: $sourceYear,
                    targetYear: $targetYear,
                    sourceYears: sourceYears,
                    targetYears: targetYears,
                    inlineSpacing: inlineSpacing,
                    controlSpacing: controlSpacing
                )
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .incomesGlassSurface(cornerRadius: surfaceCornerRadius)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(Color(.systemGroupedBackground))
    }
}
