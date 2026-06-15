import SwiftUI

struct RepeatMonthYearHeader: View {
    let year: Int

    var body: some View {
        Text(year, format: .number.grouping(.never))
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}
