//
//  RepeatMonthPicker.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import MHDesign
import SwiftUI

struct RepeatMonthPicker: View {
    @Binding private var selectedMonthSelections: Set<RepeatMonthSelection>
    private let baseDate: Date
    private let calendar: Calendar
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.control) {
            ForEach(years, id: \.self) { year in
                yearSection(for: year)
            }
            Text("Base month is always included.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    init(
        selectedMonthSelections: Binding<Set<RepeatMonthSelection>>,
        baseDate: Date,
        calendar: Calendar = .current
    ) {
        self._selectedMonthSelections = selectedMonthSelections
        self.baseDate = baseDate
        self.calendar = calendar
    }
}

private extension RepeatMonthPicker {
    var years: [Int] {
        RepeatMonthSelectionOperations.allowedYears(
            baseDate: baseDate,
            calendar: calendar
        )
    }

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

    func yearSection(for year: Int) -> some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(verbatim: "\(year)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            monthGrid(for: year)
        }
    }

    func monthGrid(for year: Int) -> some View {
        IncomesLiquidGlassControlGroup(spacing: designMetrics.spacing.inline) {
            LazyVGrid(columns: columns, spacing: designMetrics.spacing.inline) {
                ForEach(RepeatMonthSelectionOperations.validMonths, id: \.self) { month in
                    monthButton(for: .init(year: year, month: month))
                }
            }
        }
    }

    func monthButton(for selection: RepeatMonthSelection) -> some View {
        RepeatMonthButton(
            title: monthLabel(for: selection),
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

    func monthLabel(for selection: RepeatMonthSelection) -> String {
        guard let date = date(for: selection) else {
            return "\(selection.month)"
        }
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(month)/\(day)"
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

#Preview {
    RepeatMonthPicker(
        selectedMonthSelections: .constant([
            .init(year: 2_026, month: 1),
            .init(year: 2_026, month: 3),
            .init(year: 2_027, month: 4)
        ]),
        baseDate: .now
    )
}
