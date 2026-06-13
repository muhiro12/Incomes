import SwiftUI

@available(iOS 26.0, *)
enum ItemFormInputAssistProcessingState {
    case applyingSuggestions
    case scanningImage

    var title: LocalizedStringResource {
        switch self {
        case .applyingSuggestions:
            "Applying Suggestions"
        case .scanningImage:
            "Scanning Image"
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .applyingSuggestions:
            "Updating the form fields from captured text."
        case .scanningImage:
            "Reading text from the selected image."
        }
    }
}
