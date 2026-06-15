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
                RepeatMonthYearSection(
                    selectedMonthSelections: $selectedMonthSelections,
                    year: year,
                    baseDate: baseDate,
                    calendar: calendar
                )
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
