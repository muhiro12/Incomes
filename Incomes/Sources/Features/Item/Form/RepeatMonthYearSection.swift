import MHDesign
import SwiftUI

struct RepeatMonthYearSection: View {
    @Binding private var selectedMonthSelections: Set<RepeatMonthSelection>

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let year: Int
    private let baseDate: Date
    private let calendar: Calendar

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            RepeatMonthYearHeader(year: year)
            RepeatMonthGrid(
                selectedMonthSelections: $selectedMonthSelections,
                year: year,
                baseDate: baseDate,
                calendar: calendar
            )
        }
    }

    init(
        selectedMonthSelections: Binding<Set<RepeatMonthSelection>>,
        year: Int,
        baseDate: Date,
        calendar: Calendar
    ) {
        self._selectedMonthSelections = selectedMonthSelections
        self.year = year
        self.baseDate = baseDate
        self.calendar = calendar
    }
}
