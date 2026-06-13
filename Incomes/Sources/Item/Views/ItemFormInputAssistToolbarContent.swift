import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistToolbarContent: ToolbarContent {
    let isProcessing: Bool
    let isDoneDisabled: Bool
    let cancel: () -> Void
    let done: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", action: cancel)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(action: done) {
                if isProcessing {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel(Text("Processing"))
                } else {
                    Text("Done")
                }
            }
            .disabled(isDoneDisabled)
        }
    }
}
