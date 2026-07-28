import SwiftUI

struct IncomesAppRootView: View {
    let platformEnvironment: IncomesPlatformEnvironment

    var body: some View {
        ContentView()
            .incomesPlatformEnvironment(platformEnvironment)
    }
}
