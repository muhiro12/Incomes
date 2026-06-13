import MHDesign
import SwiftUI

struct RepeatMonthGrid: View {
    @Binding private var selectedMonthSelections: Set<RepeatMonthSelection>

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let year: Int
    private let baseDate: Date
    private let calendar: Calendar

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: designMetrics.spacing.inline) {
            LazyVGrid(columns: columns, spacing: designMetrics.spacing.inline) {
                ForEach(RepeatMonthSelectionOperations.validMonths, id: \.self) { month in
                    RepeatMonthSelectionButton(
                        selectedMonthSelections: $selectedMonthSelections,
                        selection: .init(year: year, month: month),
                        baseDate: baseDate,
                        calendar: calendar
                    )
                }
            }
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

private extension RepeatMonthGrid {
    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: designMetrics.spacing.inline),
            GridItem(.flexible(), spacing: designMetrics.spacing.inline),
            GridItem(.flexible(), spacing: designMetrics.spacing.inline),
            GridItem(.flexible(), spacing: designMetrics.spacing.inline)
        ]
    }
}
