import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistToolbarContent: ToolbarContent {
    let processingState: ItemFormInputAssistProcessingState?
    let isDoneDisabled: Bool
    let cancel: () -> Void
    let done: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", action: cancel)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(action: done) {
                if let processingState {
                    Label {
                        Text("Processing")
                    } icon: {
                        ProgressView()
                            .controlSize(.small)
                            .accessibilityHidden(true)
                    }
                    .labelStyle(.titleAndIcon)
                    .accessibilityLabel(Text(processingState.title))
                } else {
                    Text("Done")
                }
            }
            .disabled(isDoneDisabled)
        }
    }
}
