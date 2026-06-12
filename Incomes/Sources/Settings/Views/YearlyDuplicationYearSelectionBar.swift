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

    var body: some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            Text("Year Range")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: controlSpacing) {
                yearMenu(
                    title: "Source Year",
                    selection: $sourceYear,
                    years: sourceYears
                )
                yearMenu(
                    title: "Target Year",
                    selection: $targetYear,
                    years: targetYears
                )
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

private extension YearlyDuplicationYearSelectionBar {
    func yearMenu(
        title: LocalizedStringKey,
        selection: Binding<Int>,
        years: [Int]
    ) -> some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Picker(title, selection: selection) {
                ForEach(years, id: \.self) { year in
                    Text(verbatim: "\(year)")
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
