import MHPlatform
import SwiftData
import SwiftUI

struct SettingsListView {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(IncomesTipController.self)
    private var tipController
    @Environment(MHLoggingBootstrap.self)
    var logging

    @Environment(\.scenePhase)
    private var scenePhase

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn: Bool
    @AppStorage(\.isICloudOn)
    private var isICloudOn: Bool
    @AppStorage(\.currencyCode, default: "")
    private var currencyCode: String
    @AppStorage(\.notificationSettings, default: .init())
    private var notificationSettings: NotificationSettings
    @AppStorage(\.isDebugOn)
    private var isDebugOn: Bool

    @State private var model: SettingsScreenModel = .init()

    private let navigateToRoute: (IncomesRoute) -> Void

    init(
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        }
    ) {
        self.navigateToRoute = navigateToRoute
    }
}

extension SettingsListView: View {
    var body: some View {
        @Bindable var model = model

        List {
            SettingsSubscriptionSection(
                isSubscribeOn: isSubscribeOn,
                isICloudOn: $isICloudOn,
                openSubscription: openSubscription
            )
            SettingsCurrencySection(currencyCode: $currencyCode)
            notificationSection(
                model: model
            )
            dataManagementSection(
                model: model
            )
            tagMaintenanceSection(model: model)
            debugDataSection(model: model)
            aboutSection
            ShortcutsLinkSection()
            if isDebugOn {
                Section {
                    SettingsNavigationRowButton(
                        title: "Debug",
                        systemImage: "ladybug"
                    ) {
                        navigateToRoute(.settingsDebug)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .confirmationDialog(
            Text("Delete all"),
            isPresented: destructiveActionBinding(
                for: .deleteAll,
                model: model
            )
        ) {
            Button(role: .destructive) {
                Task {
                    dataMaintenanceLogger.notice("delete_all.requested")
                    do {
                        try await DataMaintenanceOperations.resetAllData(context: context)
                        Haptic.success.impact()
                        model.loadStatus(context: context)
                        model.dismissDestructiveAction()
                        dataMaintenanceLogger.notice("delete_all.completed")
                    } catch {
                        dataMaintenanceLogger.error(
                            "delete_all.failed",
                            metadata: IncomesLogging.errorMetadata(error)
                        )
                        assertionFailure(error.localizedDescription)
                    }
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                model.dismissDestructiveAction()
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete all items?")
        }
        .confirmationDialog(
            Text("Delete debug sample data"),
            isPresented: destructiveActionBinding(
                for: .deleteDebugData,
                model: model
            )
        ) {
            Button(role: .destructive) {
                do {
                    dataMaintenanceLogger.notice(
                        "debug_data.delete_confirmed",
                        metadata: IncomesLogging.metadata(
                            ("has_debug_data", IncomesLogging.bool(model.hasDebugData))
                        )
                    )
                    try DataMaintenanceOperations.deleteDebugData(context: context)
                    Haptic.success.impact()
                    model.loadStatus(context: context)
                    model.dismissDestructiveAction()
                    dataMaintenanceLogger.notice("debug_data.delete_completed")
                } catch {
                    dataMaintenanceLogger.error(
                        "debug_data.delete_failed",
                        metadata: IncomesLogging.errorMetadata(error)
                    )
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                model.dismissDestructiveAction()
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("This will remove debug sample items and tags. Continue?")
        }
        .task {
            model.apply(notificationSettings: notificationSettings)
            await notificationService.refreshAuthorizationStatus()
        }
        .task {
            await loadDeferredSettingsState()
        }
        .task(id: notificationSettings) {
            withAnimation {
                model.apply(notificationSettings: notificationSettings)
            }

            await SettingsActionCoordinator.refreshNotifications(
                notificationService: notificationService
            )
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else {
                return
            }

            await notificationService.refreshAuthorizationStatus()
        }
    }
}

private extension SettingsListView {
    @MainActor
    func loadDeferredSettingsState() async {
        await Task.yield()

        model.loadStatus(context: context)

        await SettingsActionCoordinator.refreshNotifications(
            notificationService: notificationService
        )
    }
}

private extension SettingsListView {
    var appVersionText: String? {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return nil
        }
        return "\(version) (\(build))"
    }

    var aboutSection: some View {
        SettingsAboutSection(
            showTipsAgain: resetTips,
            openLicense: {
                navigateToRoute(.settingsLicense)
            },
            versionText: appVersionText
        )
    }

    func notificationSection(
        model: SettingsScreenModel
    ) -> some View {
        SettingsNotificationSection(
            notificationSettings: $notificationSettings,
            isNotificationEnabled: model.isNotificationEnabled,
            authorizationPresentation: model.authorizationPresentation(
                for: notificationService.authorizationState
            ),
            sendTestNotification: {
                notificationService.sendTestNotification()
            },
            openSystemSettings: openSystemSettings
        )
    }

    func dataManagementSection(
        model: SettingsScreenModel
    ) -> some View {
        SettingsDataManagementSection(
            showsYearlyDuplicationTip: !yearTags.isEmpty,
            duplicateYearItems: duplicateYearItems,
            deleteAllItems: deleteAllItemsAction(model: model)
        )
    }

    func resetTips() {
        do {
            try tipController.resetTips(hasAnyItems: !yearTags.isEmpty)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func tagMaintenanceSection(
        model: SettingsScreenModel
    ) -> some View {
        SettingsTagMaintenanceSection(
            hasDuplicateTags: model.hasDuplicateTags,
            hasOrphanTags: model.hasOrphanTags,
            openDuplicateTags: {
                navigateToRoute(.duplicateTags)
            },
            openOrphanTags: {
                navigateToRoute(.orphanTags)
            }
        )
    }

    func debugDataSection(
        model: SettingsScreenModel
    ) -> some View {
        SettingsDebugDataSection(
            hasDebugData: model.hasDebugData,
            deleteDebugData: debugDataDeleteAction(model: model)
        )
    }

    func debugDataDeleteAction(
        model: SettingsScreenModel
    ) -> () -> Void {
        {
            promptDeleteDebugData(model: model)
        }
    }

    func duplicateYearItems() {
        tipController.donateDidOpenYearlyDuplication()
        navigateToRoute(.yearlyDuplication)
    }

    func openSubscription() {
        tipController.donateDidOpenSubscription()
        navigateToRoute(.settingsSubscription)
    }

    func deleteAllItemsAction(
        model: SettingsScreenModel
    ) -> () -> Void {
        {
            Haptic.warning.impact()
            dataMaintenanceLogger.notice("delete_all.prompt_presented")
            model.presentDestructiveAction(.deleteAll)
        }
    }

    func promptDeleteDebugData(
        model: SettingsScreenModel
    ) {
        Haptic.warning.impact()
        dataMaintenanceLogger.notice(
            "debug_data.delete_requested",
            metadata: IncomesLogging.metadata(
                ("has_debug_data", IncomesLogging.bool(model.hasDebugData))
            )
        )
        model.presentDestructiveAction(.deleteDebugData)
    }

    func destructiveActionBinding(
        for action: SettingsScreenModel.DestructiveAction,
        model: SettingsScreenModel
    ) -> Binding<Bool> {
        .init(
            get: {
                model.isPresenting(action)
            },
            set: { isPresented in
                if !isPresented {
                    model.dismissDestructiveAction()
                }
            }
        )
    }

    func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}
