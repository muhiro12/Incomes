//
//  RepeatMonthPicker.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftUI

struct RepeatMonthPicker: View {
    @Binding private var selectedMonthSelections: Set<RepeatMonthSelection>
    private let baseDate: Date
    private let calendar: Calendar

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    init(
        selectedMonthSelections: Binding<Set<RepeatMonthSelection>>,
        baseDate: Date,
        calendar: Calendar = .current
    ) {
        self._selectedMonthSelections = selectedMonthSelections
        self.baseDate = baseDate
        self.calendar = calendar
    }

    var body: some View {
        let currentBaseYear = baseYear
        let years = [currentBaseYear, currentBaseYear + 1]
        VStack(alignment: .leading, spacing: 16) {
            ForEach(years, id: \.self) { year in
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "\(year)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(1...12, id: \.self) { month in
                            let selection = RepeatMonthSelection(year: year, month: month)
                            Button {
                                toggleSelection(selection)
                            } label: {
                                Text(verbatim: monthLabel(for: selection))
                                    .font(.callout)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            .background(backgroundColor(for: selection))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(borderColor(for: selection), lineWidth: 1)
                            )
                            .disabled(selection == baseSelection)
                        }
                    }
                }
            }
            Text(String(localized: "Base month is always included."))
                .font(.footnote)
                .foregroundStyle(.secondary)
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

    func backgroundColor(for selection: RepeatMonthSelection) -> Color {
        if isSelected(selection) {
            return Color.accentColor.opacity(0.2)
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
        let baseMonth = baseMonth
        let baseYear = baseYear
        return (selection.year - baseYear) * 12 + (selection.month - baseMonth)
    }

    var baseYear: Int {
        calendar.component(.year, from: baseDate)
    }

    var baseMonth: Int {
        calendar.component(.month, from: baseDate)
    }

    var baseSelection: RepeatMonthSelection {
        .init(year: baseYear, month: baseMonth)
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
