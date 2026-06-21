import MHDesign
import SwiftUI

struct RepeatMonthGrid: View {
    private enum Constants {
        static let defaultColumnCount = 4
        static let accessibilityColumnCount = 2
    }

    @Binding private var selectedMonthSelections: Set<RepeatMonthSelection>

    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

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
        .init(
            repeating: GridItem(.flexible(), spacing: designMetrics.spacing.inline),
            count: columnCount
        )
    }

    var columnCount: Int {
        if dynamicTypeSize.isAccessibilitySize {
            return Constants.accessibilityColumnCount
        }
        return Constants.defaultColumnCount
    }
}
