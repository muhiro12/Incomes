import MHDesign
import SwiftUI

struct RepeatMonthButton: View {
    private enum Constants {
        static let borderLineWidth: CGFloat = 1
        static let selectedBackgroundOpacity = 0.2
        static let selectedGlassTintOpacity = 0.22
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let date: Date?
    let fallbackMonth: Int
    let calendar: Calendar
    let isIncluded: Bool
    let isBaseSelection: Bool
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            button
                .incomesGlassEffect(
                    cornerRadius: designMetrics.cornerRadius.control,
                    tint: glassTint,
                    isInteractive: !isBaseSelection
                )
                .overlay(buttonBorder)
        } else {
            button
                .background(fallbackBackgroundColor)
                .clipShape(buttonShape)
                .overlay(buttonBorder)
        }
    }
}

private extension RepeatMonthButton {
    var button: some View {
        Button(action: action) {
            labelText
                .environment(\.calendar, calendar)
                .font(.callout)
                .padding(.horizontal, designMetrics.spacing.inline)
                .frame(
                    maxWidth: .infinity,
                    minHeight: designMetrics.layout.control.minimumTouchTarget
                )
        }
        .buttonStyle(.plain)
        .disabled(isBaseSelection)
        .accessibilityValue(accessibilitySelectionValue)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isIncluded ? .isSelected : [])
    }

    var labelText: Text {
        guard let date else {
            return Text(fallbackMonth, format: .number)
        }
        return Text(date, format: .dateTime.month().day())
    }

    var buttonBorder: some View {
        buttonShape
            .stroke(
                borderColor,
                lineWidth: Constants.borderLineWidth
            )
    }

    var buttonShape: RoundedRectangle {
        .init(
            cornerRadius: designMetrics.cornerRadius.control,
            style: .continuous
        )
    }

    var borderColor: Color {
        if isIncluded {
            return Color.accentColor
        }
        return Color(.separator)
    }

    var fallbackBackgroundColor: Color {
        if isIncluded {
            return Color.accentColor.opacity(Constants.selectedBackgroundOpacity)
        }
        return Color(.secondarySystemBackground)
    }

    @available(iOS 26.0, *)
    var glassTint: Color? {
        guard isIncluded else {
            return nil
        }
        return Color.accentColor.opacity(Constants.selectedGlassTintOpacity)
    }

    var accessibilitySelectionValue: Text {
        if isIncluded {
            return Text("Selected")
        }
        return Text("Not Selected")
    }

    var accessibilityHint: Text {
        if isBaseSelection {
            return Text("Base month is always included.")
        }
        return Text("Toggles this repeat month.")
    }
}
