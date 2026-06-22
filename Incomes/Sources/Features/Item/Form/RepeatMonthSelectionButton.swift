import SwiftUI

struct RepeatMonthSelectionButton: View {
    @Binding private var selectedMonthSelections: Set<RepeatMonthSelection>

    private let selection: RepeatMonthSelection
    private let baseDate: Date
    private let calendar: Calendar

    var body: some View {
        RepeatMonthButton(
            date: date,
            fallbackMonth: selection.month,
            calendar: calendar,
            isIncluded: isIncluded,
            isBaseSelection: isBaseSelection
        ) {
            toggleSelection()
        }
    }

    init(
        selectedMonthSelections: Binding<Set<RepeatMonthSelection>>,
        selection: RepeatMonthSelection,
        baseDate: Date,
        calendar: Calendar
    ) {
        self._selectedMonthSelections = selectedMonthSelections
        self.selection = selection
        self.baseDate = baseDate
        self.calendar = calendar
    }
}

private extension RepeatMonthSelectionButton {
    var baseSelection: RepeatMonthSelection {
        RepeatMonthSelectionOperations.baseSelection(
            baseDate: baseDate,
            calendar: calendar
        )
    }

    var isBaseSelection: Bool {
        selection == baseSelection
    }

    var isSelected: Bool {
        selectedMonthSelections.contains(selection)
    }

    var isIncluded: Bool {
        isBaseSelection || isSelected
    }

    var date: Date? {
        calendar.date(
            byAdding: .month,
            value: monthOffset,
            to: baseDate
        )
    }

    var monthOffset: Int {
        RepeatMonthSelectionOperations.monthOffset(
            from: baseDate,
            to: selection,
            calendar: calendar
        )
    }

    func toggleSelection() {
        guard !isBaseSelection else {
            return
        }
        if selectedMonthSelections.contains(selection) {
            selectedMonthSelections.remove(selection)
        } else {
            selectedMonthSelections.insert(selection)
        }
    }
}
