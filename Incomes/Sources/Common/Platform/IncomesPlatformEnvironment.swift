import MHPlatform
import SwiftData
import SwiftUI

struct IncomesPlatformEnvironment {
    let modelContainer: ModelContainer
    let notificationService: NotificationService
    let configurationService: ConfigurationService
    let tipController: IncomesTipController
    let routeBridge: IncomesRouteBridge
    let runtimeBootstrap: MHAppRuntimeBootstrap
}

extension View {
    func incomesPlatformEnvironment(
        _ environment: IncomesPlatformEnvironment
    ) -> some View {
        modelContainer(environment.modelContainer)
            .environment(environment.notificationService)
            .environment(environment.configurationService)
            .environment(environment.tipController)
            .environment(environment.routeBridge)
            .mhAppRuntimeBootstrap(environment.runtimeBootstrap)
    }
}
