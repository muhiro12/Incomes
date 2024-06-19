import SwiftUI

struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(Color(.secondaryLabel), Color(.secondarySystemFill))
                .font(.title3)
        }
    }
}

#Preview {
    CloseButton()
}
