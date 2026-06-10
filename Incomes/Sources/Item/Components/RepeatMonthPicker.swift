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
            Text(String(localized: "Base month is always included."))
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
    private enum Constants {
        static let borderLineWidth: CGFloat = 1
        static let selectedBackgroundOpacity = 0.2
    }

    var years: [Int] {
        RepeatMonthSelectionRules.allowedYears(
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
        RepeatMonthSelectionRules.baseSelection(
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
        LazyVGrid(columns: columns, spacing: designMetrics.spacing.inline) {
            ForEach(RepeatMonthSelectionRules.allowedMonths, id: \.self) { month in
                monthButton(for: .init(year: year, month: month))
            }
        }
    }

    func monthButton(for selection: RepeatMonthSelection) -> some View {
        Button {
            toggleSelection(selection)
        } label: {
            Text(verbatim: monthLabel(for: selection))
                .font(.callout)
                .padding(.horizontal, designMetrics.spacing.inline)
                .frame(
                    maxWidth: .infinity,
                    minHeight: designMetrics.layout.control.minimumTouchTarget
                )
        }
        .buttonStyle(.plain)
        .background(backgroundColor(for: selection))
        .clipShape(
            RoundedRectangle(
                cornerRadius: designMetrics.cornerRadius.control,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: designMetrics.cornerRadius.control,
                style: .continuous
            )
            .stroke(
                borderColor(for: selection),
                lineWidth: Constants.borderLineWidth
            )
        )
        .disabled(selection == baseSelection)
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

    func backgroundColor(for selection: RepeatMonthSelection) -> Color {
        if isSelected(selection) {
            return Color.accentColor.opacity(Constants.selectedBackgroundOpacity)
        }
        return Color(.secondarySystemBackground)
    }

    func borderColor(for selection: RepeatMonthSelection) -> Color {
        if isSelected(selection) {
            return Color.accentColor
        }
        return Color(.separator)
    }

    func isSelected(_ selection: RepeatMonthSelection) -> Bool {
        selectedMonthSelections.contains(selection)
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
        RepeatMonthSelectionRules.monthOffset(
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
