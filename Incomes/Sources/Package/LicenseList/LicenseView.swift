import SwiftUI

struct LicenseView: View {
    @Environment(LicenseListPackage.self) private var licenseList

    var body: some View {
        licenseList()
            .navigationTitle(Text("License"))
    }
}

#Preview {
    LicenseView()
}
