import LicenseList
import SwiftUI

struct LicenseView: View {
    var body: some View {
        LicenseList.LicenseListView()
            .licenseViewStyle(.withRepositoryAnchorLink)
            .navigationTitle("License")
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        LicenseView()
    }
}
