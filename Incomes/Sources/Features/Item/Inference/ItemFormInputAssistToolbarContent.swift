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
            .accessibilityHint(doneAccessibilityHint)
        }
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistToolbarContent {
    var doneAccessibilityHint: Text {
        if let processingState {
            return Text("Wait until \(processingState.title) finishes.")
        }
        if isDoneDisabled {
            return Text("Capture or enter text to apply suggestions.")
        }
        return Text("Applies suggestions to the item form.")
    }
}
