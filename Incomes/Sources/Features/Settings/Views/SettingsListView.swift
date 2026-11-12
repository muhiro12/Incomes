import MHPlatform
import SwiftData
import SwiftUI

struct SettingsListView {
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(IncomesTipController.self)
    private var tipController

    @Environment(\.selectedLedgerIdentifier)
    private var selectedLedgerIdentifier

    @Environment(\.scenePhase)
    private var scenePhase

    @Query private var yearTags: [Tag]

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn: Bool
    @AppStorage(\.isICloudOn)
    private var isICloudOn: Bool
    @AppStorage(\.currencyCode, default: "")
    private var currencyCode: String
    @AppStorage(\.notificationSettings, default: .init())
    private var notificationSettings: NotificationSettings

    @State private var model: SettingsScreenModel = .init()
    @State private var errorMessage: String?

    private let navigateToRoute: (IncomesRoute) -> Void

    init(
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        }
    ) {
        self.navigateToRoute = navigateToRoute
        _yearTags = .init(.tags(.typeIs(.year)))
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
            preferencesSection(model: model)
            SettingsDataNavigationSection(
                selectedLedgerIdentifier: selectedLedgerIdentifier,
                duplicateYearItems: duplicateYearItems
            )
            Section {
                NavigationLink(value: SettingsNavigationDestination.advanced) {
                    Label("Advanced", systemImage: "gearshape.2")
                }
            }
            aboutSection
            ShortcutsLinkSection()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Settings")
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .task {
            model.apply(notificationSettings: notificationSettings)
            await notificationService.refreshAuthorizationStatus()
        }
        .onChange(of: scenePhase) {
            guard scenePhase == .active else {
                return
            }

            Task {
                await notificationService.refreshAuthorizationStatus()
            }
        }
    }
}

private extension SettingsListView {
    var appVersionText: String? {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else {
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
            onError: { message in
                errorMessage = message
            },
            versionText: appVersionText
        )
    }

    var notificationSettingsBinding: Binding<NotificationSettings> {
        .init(
            get: {
                notificationSettings
            },
            set: { newSettings in
                guard newSettings != notificationSettings else {
                    return
                }

                notificationSettings = newSettings
                withAnimation {
                    model.apply(notificationSettings: newSettings)
                }
                Task {
                    await SettingsActionCoordinator.refreshNotifications(
                        notificationService: notificationService
                    )
                }
            }
        )
    }

    func notificationLink(model: SettingsScreenModel) -> some View {
        NavigationLink {
            Form {
                SettingsNotificationSection(
                    notificationSettings: notificationSettingsBinding,
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
            .navigationTitle("Push notification settings")
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            Label("Push notification settings", systemImage: "bell.badge")
        }
    }

    func preferencesSection(model: SettingsScreenModel) -> some View {
        Section("Preferences") {
            Picker("Currency Code", selection: $currencyCode) {
                ForEach(CurrencyCode.allCases, id: \.rawValue) { code in
                    Text(code.displayName)
                }
            }
            notificationLink(model: model)
        }
    }

    func resetTips() {
        do {
            try tipController.resetTips(hasAnyItems: !yearTags.isEmpty)
        } catch {
            assertionFailure(error.localizedDescription)
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

    func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}
