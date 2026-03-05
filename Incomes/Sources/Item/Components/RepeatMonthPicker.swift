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
        GridItem(.flexible(), spacing: 8), // swiftlint:disable:this no_magic_numbers
        GridItem(.flexible(), spacing: 8), // swiftlint:disable:this no_magic_numbers
        GridItem(.flexible(), spacing: 8), // swiftlint:disable:this no_magic_numbers
        GridItem(.flexible(), spacing: 8) // swiftlint:disable:this no_magic_numbers
    ]

    init( // swiftlint:disable:this type_contents_order
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
        VStack(alignment: .leading, spacing: 16) { // swiftlint:disable:this closure_body_length no_magic_numbers
            ForEach(years, id: \.self) { year in
                VStack(alignment: .leading, spacing: 8) { // swiftlint:disable:this no_magic_numbers
                    Text(verbatim: "\(year)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: columns, spacing: 8) { // swiftlint:disable:this no_magic_numbers
                        ForEach(1...12, id: \.self) { month in // swiftlint:disable:this no_magic_numbers
                            let selection = RepeatMonthSelection(year: year, month: month)
                            Button {
                                toggleSelection(selection)
                            } label: {
                                Text(verbatim: monthLabel(for: selection))
                                    .font(.callout)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8) // swiftlint:disable:this no_magic_numbers
                            }
                            .buttonStyle(.plain)
                            .background(backgroundColor(for: selection))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous)) // swiftlint:disable:this line_length no_magic_numbers
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous) // swiftlint:disable:this line_length no_magic_numbers
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

    func toggleSelection(_ selection: RepeatMonthSelection) { // swiftlint:disable:this type_contents_order
        guard selection != baseSelection else {
            return
        }
        if selectedMonthSelections.contains(selection) {
            selectedMonthSelections.remove(selection)
        } else {
            selectedMonthSelections.insert(selection)
        }
    }

    func backgroundColor(for selection: RepeatMonthSelection) -> Color { // swiftlint:disable:this type_contents_order
        if isSelected(selection) {
            return Color.accentColor.opacity(0.2) // swiftlint:disable:this no_magic_numbers
        }
        return Color(.secondarySystemBackground)
    }

    func borderColor(for selection: RepeatMonthSelection) -> Color { // swiftlint:disable:this type_contents_order
        if isSelected(selection) {
            return Color.accentColor
        }
        return Color(.separator)
    }

    func isSelected(_ selection: RepeatMonthSelection) -> Bool { // swiftlint:disable:this type_contents_order
        selectedMonthSelections.contains(selection)
    }

    func monthLabel(for selection: RepeatMonthSelection) -> String { // swiftlint:disable:this type_contents_order
        guard let date = date(for: selection) else {
            return "\(selection.month)"
        }
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(month)/\(day)"
    }

    func date(for selection: RepeatMonthSelection) -> Date? { // swiftlint:disable:this type_contents_order
        let monthOffset = monthOffset(for: selection)
        return calendar.date(byAdding: .month, value: monthOffset, to: baseDate)
    }

    func monthOffset(for selection: RepeatMonthSelection) -> Int { // swiftlint:disable:this type_contents_order
        let baseMonth = baseMonth
        let baseYear = baseYear
        return (selection.year - baseYear) * 12 + (selection.month - baseMonth) // swiftlint:disable:this line_length no_magic_numbers
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
