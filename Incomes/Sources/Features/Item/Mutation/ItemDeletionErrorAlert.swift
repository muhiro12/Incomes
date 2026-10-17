import SwiftUI

private struct ItemDeletionErrorAlert: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content.alert(
            "Error",
            isPresented: .init(
                get: {
                    message != nil
                },
                set: { isPresented in
                    if !isPresented {
                        message = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                message = nil
            }
        } message: {
            Text(message ?? "")
        }
    }
}

extension View {
    func itemDeletionErrorAlert(_ message: Binding<String?>) -> some View {
        modifier(ItemDeletionErrorAlert(message: message))
    }
}
