import SwiftUI

struct StoreSubscriptionPolicySection: View {
    private static let termsURLString = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    private static let privacyURLString = "https://muhiro12.github.io/Incomes/privacy"

    private let termsURL = URL(string: Self.termsURLString)
    private let privacyURL = URL(string: Self.privacyURLString)

    var body: some View {
        Section {
            if let termsURL {
                Link("Terms of Service", destination: termsURL)
            }
            if let privacyURL {
                Link("Privacy Policy", destination: privacyURL)
            }
        }
    }
}
