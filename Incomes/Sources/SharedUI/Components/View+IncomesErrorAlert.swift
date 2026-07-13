import SwiftUI

struct ErrorAlertPresentation {
    let title: LocalizedStringKey
    let message: String

    init(
        title: LocalizedStringKey,
        error: Error
    ) {
        self.title = title
        message = ErrorMessageOperations.message(from: error)
    }
}

extension View {
    func incomesErrorAlert(
        _ title: LocalizedStringKey,
        message: Binding<String?>
    ) -> some View {
        alert(
            title,
            isPresented: .init(
                get: {
                    message.wrappedValue != nil
                },
                set: { isPresented in
                    if !isPresented {
                        message.wrappedValue = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                message.wrappedValue = nil
            }
        } message: {
            Text(verbatim: message.wrappedValue ?? "")
        }
    }

    func incomesErrorAlert(
        _ presentation: Binding<ErrorAlertPresentation?>
    ) -> some View {
        alert(
            presentation.wrappedValue?.title ?? "",
            isPresented: .init(
                get: {
                    presentation.wrappedValue != nil
                },
                set: { isPresented in
                    if !isPresented {
                        presentation.wrappedValue = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                presentation.wrappedValue = nil
            }
        } message: {
            Text(verbatim: presentation.wrappedValue?.message ?? "")
        }
    }
}
