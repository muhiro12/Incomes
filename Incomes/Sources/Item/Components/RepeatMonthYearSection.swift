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
            Text(year, format: .number.grouping(.never))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            IncomesLiquidGlassControlGroup(spacing: designMetrics.spacing.inline) {
                LazyVGrid(columns: columns, spacing: designMetrics.spacing.inline) {
                    ForEach(RepeatMonthSelectionOperations.validMonths, id: \.self) { month in
                        monthButton(for: .init(year: year, month: month))
                    }
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

private extension RepeatMonthYearSection {
    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: designMetrics.spacing.inline),
            GridItem(.flexible(), spacing: designMetrics.spacing.inline),
            GridItem(.flexible(), spacing: designMetrics.spacing.inline),
            GridItem(.flexible(), spacing: designMetrics.spacing.inline)
        ]
    }

    var baseSelection: RepeatMonthSelection {
        RepeatMonthSelectionOperations.baseSelection(
            baseDate: baseDate,
            calendar: calendar
        )
    }

    func monthButton(for selection: RepeatMonthSelection) -> some View {
        RepeatMonthButton(
            date: date(for: selection),
            fallbackMonth: selection.month,
            calendar: calendar,
            isIncluded: isIncluded(selection),
            isBaseSelection: selection == baseSelection
        ) {
            toggleSelection(selection)
        }
    }

    func toggleSelection(_ selection: RepeatMonthSelection) {
        guard selection != baseSelection else {
            return
        }
        if selectedMonthSelections.contains(selection) {
            selectedMonthSelections.remove(selection)
        } else {
            selectedMonthSelections.insert(selection)
        }
    }

    func isSelected(_ selection: RepeatMonthSelection) -> Bool {
        selectedMonthSelections.contains(selection)
    }

    func isIncluded(_ selection: RepeatMonthSelection) -> Bool {
        selection == baseSelection || isSelected(selection)
    }

    func date(for selection: RepeatMonthSelection) -> Date? {
        let monthOffset = monthOffset(for: selection)
        return calendar.date(byAdding: .month, value: monthOffset, to: baseDate)
    }

    func monthOffset(for selection: RepeatMonthSelection) -> Int {
        RepeatMonthSelectionOperations.monthOffset(
            from: baseDate,
            to: selection,
            calendar: calendar
        )
    }
}
