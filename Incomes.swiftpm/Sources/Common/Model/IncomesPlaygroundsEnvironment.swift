import SwiftUI

extension View {
    func incomesPlaygroundsEnvironment() -> some View {
        incomesEnvironment(
            googleMobileAds: {
                placeholder("GoogleMobileAds \($0)")
            },
            licenseList: {
                placeholder("LicenseList")
            },
            storeKit: {
                placeholder("StoreKit")
            }
        )
    }

    private func placeholder(_ string: String) -> some View {
        Text(string)
            .frame(width: 240, height: 160)
            .font(.headline)
            .foregroundStyle(.placeholder)
            .background(.placeholder.quinary)
            .clipShape(.rect(cornerRadius: 8))
            .padding()
    }
}
