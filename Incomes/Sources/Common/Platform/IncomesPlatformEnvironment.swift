import MHPlatform
import SwiftData
import SwiftUI

struct IncomesPlatformEnvironment {
    let modelContainer: ModelContainer
    let notificationService: NotificationService
    let configurationService: ConfigurationService
    let tipController: IncomesTipController
    let appRuntime: MHAppRuntime
}

extension View {
    func incomesPlatformEnvironment(
        _ environment: IncomesPlatformEnvironment
    ) -> some View {
        modelContainer(environment.modelContainer)
            .environment(environment.notificationService)
            .environment(environment.configurationService)
            .environment(environment.tipController)
            .environment(environment.appRuntime)
    }
}
