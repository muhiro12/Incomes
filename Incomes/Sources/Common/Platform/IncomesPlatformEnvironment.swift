import MHPlatform
import SwiftData
import SwiftUI

typealias IncomesRouteInbox = MHObservableRouteInbox<IncomesRoute>

struct IncomesPlatformEnvironment {
    let modelContainer: ModelContainer
    let notificationService: NotificationService
    let remoteConfigurationService: RemoteConfigurationService
    let tipController: IncomesTipController
    let routeInbox: IncomesRouteInbox
    let runtimeBootstrap: MHAppRuntimeBootstrap
}

extension View {
    func incomesPlatformEnvironment(
        _ environment: IncomesPlatformEnvironment
    ) -> some View {
        incomesBasePlatformEnvironment(environment)
            .mhAppRuntimeBootstrap(environment.runtimeBootstrap)
    }

    func incomesPreviewPlatformEnvironment(
        _ environment: IncomesPlatformEnvironment
    ) -> some View {
        incomesBasePlatformEnvironment(environment)
            .mhAppRuntimeEnvironment(environment.runtimeBootstrap)
    }

    private func incomesBasePlatformEnvironment(
        _ environment: IncomesPlatformEnvironment
    ) -> some View {
        modelContainer(environment.modelContainer)
            .environment(environment.notificationService)
            .environment(environment.remoteConfigurationService)
            .environment(environment.tipController)
            .environment(environment.routeInbox)
    }
}
