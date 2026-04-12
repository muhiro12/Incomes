import MHPlatform
import SwiftUI

struct IncomesAppRootView: View {
    @AppStorage(BoolAppStorageKey.isICloudOn)
    private var isICloudOn

    let platformEnvironment: IncomesPlatformEnvironment

    var body: some View {
        ContentView()
            .id(isICloudOn)
            .incomesPlatformEnvironment(platformEnvironment)
    }
}
