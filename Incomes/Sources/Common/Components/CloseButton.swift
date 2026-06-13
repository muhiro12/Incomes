import SwiftUI

struct CloseButton: View {
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        button
            .incomesDismissControlStyle()
    }

    private var button: some View {
        Button {
            dismiss()
        } label: {
            label
        }
        .accessibilityLabel(Text("Close"))
    }

    private var label: some View {
        Label {
            Text("Close")
        } icon: {
            if #available(iOS 26.0, *) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.secondary)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(
                        Color.secondary,
                        FillShapeStyle.fill
                    )
                    .font(.title2)
                    .accessibilityHidden(true)
            }
        }
        .labelStyle(.iconOnly)
    }
}

#Preview {
    NavigationStack {
        List {
            CloseButton()
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}
