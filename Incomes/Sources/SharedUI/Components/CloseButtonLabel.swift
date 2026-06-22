import SwiftUI

struct CloseButtonLabel: View {
    var body: some View {
        Label {
            Text("Close")
        } icon: {
            icon
        }
        .labelStyle(.iconOnly)
    }

    @ViewBuilder private var icon: some View {
        if #available(iOS 26.0, *) {
            Image(systemName: "xmark")
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
}
