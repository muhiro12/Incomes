//
//  RepeatMonthPicker.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftUI

struct RepeatMonthPicker: View {
    @Binding private var selectedMonths: Set<Int>
    private let baseMonth: Int

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    init(selectedMonths: Binding<Set<Int>>, baseMonth: Int) {
        self._selectedMonths = selectedMonths
        self.baseMonth = baseMonth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...12, id: \.self) { month in
                    Button {
                        toggleMonth(month)
                    } label: {
                        Text(verbatim: "\(month)")
                            .font(.callout)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .background(backgroundColor(for: month))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(borderColor(for: month), lineWidth: 1)
                    )
                    .disabled(month == baseMonth)
                }
            }
            Text(String(localized: "Base month is always included."))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func toggleMonth(_ month: Int) {
        guard month != baseMonth else {
            return
        }
        if selectedMonths.contains(month) {
            selectedMonths.remove(month)
        } else {
            selectedMonths.insert(month)
        }
    }

    func backgroundColor(for month: Int) -> Color {
        if isSelected(month) {
            return Color.accentColor.opacity(0.2)
        }
        return Color(.secondarySystemBackground)
    }

    func borderColor(for month: Int) -> Color {
        if isSelected(month) {
            return Color.accentColor
        }
        return Color(.separator)
    }

    func isSelected(_ month: Int) -> Bool {
        selectedMonths.contains(month)
    }
}

#Preview {
    RepeatMonthPicker(
        selectedMonths: .constant([1, 3, 4]),
        baseMonth: 4
    )
}
