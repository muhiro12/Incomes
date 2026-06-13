import SwiftUI

struct YearlyDuplicationYearMenu: View {
    let title: LocalizedStringKey
    @Binding var selection: Int
    let years: [Int]
    let inlineSpacing: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Picker(title, selection: $selection) {
                ForEach(years, id: \.self) { year in
                    Text(year, format: .number.grouping(.never))
                }
            }
            .pickerStyle(.menu)
            .incomesSecondaryControlStyle()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
