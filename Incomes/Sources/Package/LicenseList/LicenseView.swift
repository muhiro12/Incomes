import MHPlatform
import SwiftUI

struct LicenseView: View {
    @Environment(MHAppRuntime.self)
    private var appRuntime

    var body: some View {
        appRuntime.licensesView()
            .navigationTitle("License")
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        LicenseView()
    }
}
