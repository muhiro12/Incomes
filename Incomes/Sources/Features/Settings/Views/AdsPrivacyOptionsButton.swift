import MHPlatform
import SwiftUI

struct AdsPrivacyOptionsButton: View {
    @Environment(MHAppRuntime.self)
    private var appRuntime

    @State private var isPresentingPrivacyOptions = false

    let onError: (String) -> Void

    var body: some View {
        if appRuntime.adsPrivacyOptionsRequirement == .required {
            Button("Privacy Options") {
                presentPrivacyOptions()
            }
            .disabled(isPresentingPrivacyOptions)
        }
    }
}

private extension AdsPrivacyOptionsButton {
    func presentPrivacyOptions() {
        guard isPresentingPrivacyOptions == false else {
            return
        }
        isPresentingPrivacyOptions = true

        Task {
            defer {
                isPresentingPrivacyOptions = false
            }
            do {
                try await appRuntime.presentAdsPrivacyOptions()
            } catch {
                onError(ErrorMessageOperations.message(from: error))
            }
        }
    }
}
