import MHPlatform
import SwiftData
import SwiftUI

struct IncomesPlatformEnvironment {
    let modelContainer: ModelContainer
    let notificationService: NotificationService
    let remoteConfigurationService: RemoteConfigurationService
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
            .environment(environment.remoteConfigurationService)
            .environment(environment.tipController)
            .environment(environment.routeBridge)
            .mhAppRuntimeBootstrap(environment.runtimeBootstrap)
    }
}
