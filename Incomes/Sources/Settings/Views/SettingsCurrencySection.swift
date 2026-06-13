import SwiftUI

struct SettingsCurrencySection: View {
    @Binding var currencyCode: String

    var body: some View {
        Section {
            Picker(selection: $currencyCode) {
                ForEach(CurrencyCode.allCases, id: \.rawValue) { code in
                    Text(code.displayName)
                }
            } label: {
                Text("Currency Code")
            }
        }
    }
}
