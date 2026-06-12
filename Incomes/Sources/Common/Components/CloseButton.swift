import SwiftUI

struct CloseButton: View {
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
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
        .accessibilityLabel(Text("Close"))
    }
}

#Preview {
    NavigationView {
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
