import SwiftUI

struct DebugNaturalLanguageSearchMessageSection: View {
    let error: NaturalLanguageSearchError

    var body: some View {
        Section {
            Label {
                message
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
        } footer: {
            Text("No search was run. Rephrase the request, or use Search to filter saved items manually.")
        }
    }
}

private extension DebugNaturalLanguageSearchMessageSection {
    var message: Text {
        switch error {
        case .emptyRequest:
            Text("Enter what you want to find.")
        case .requestTooLong:
            Text("Shorten the request to \(NaturalLanguageSearchOperations.maximumRequestLength) characters or fewer.")
        case .unsupportedAction:
            Text("This search only finds saved items. It can't add, change, or delete them.")
        case .unsupportedRequest:
            Text("The request doesn't look like a search for saved items.")
        case .unsupportedTerms(let terms):
            Text("These terms aren't supported as search conditions: \(terms.formatted(.list(type: .and)))")
        case .noConditions:
            Text("No supported search condition was found.")
        case .ungroundedContent:
            Text("The interpreted item name isn't in your request.")
        case .contradictoryMonth:
            Text("The request names conflicting months.")
        case .missingMonth:
            Text("Include a month with the year.")
        case .invalidMonth:
            Text("The interpreted month isn't a valid calendar month.")
        case .missingAmount(.income):
            Text("Include an amount for the income condition.")
        case .missingAmount(.outgo):
            Text("Include an amount for the outgo condition.")
        case .invalidAmount(.income):
            Text("The interpreted income amount isn't a supported number.")
        case .invalidAmount(.outgo):
            Text("The interpreted outgo amount isn't a supported number.")
        case .invertedRange(.income):
            Text("The minimum income is greater than the maximum.")
        case .invertedRange(.outgo):
            Text("The minimum outgo is greater than the maximum.")
        case .unavailableModel:
            Text("The on-device language model is unavailable on this device.")
        case .unsupportedLocale:
            Text("The on-device language model doesn't support the current language.")
        case .generationFailed:
            Text("The request couldn't be interpreted.")
        }
    }
}
