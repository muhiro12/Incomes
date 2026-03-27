import MHPlatform
import SwiftData
import SwiftUI
import TipKit

struct SettingsListView {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(IncomesTipController.self)
    private var tipController

    @Environment(\.scenePhase)
    private var scenePhase

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]

    @AppStorage(BoolAppStorageKey.isSubscribeOn)
    private var isSubscribeOn: Bool
    @AppStorage(BoolAppStorageKey.isICloudOn)
    private var isICloudOn: Bool
    @AppStorage(StringAppStorageKey.currencyCode, default: "")
    private var currencyCode: String
    @AppStorage(NotificationSettingsAppStorageKey.notificationSettings, default: .init())
    private var notificationSettings: NotificationSettings
    @AppStorage(BoolAppStorageKey.isDebugOn)
    private var isDebugOn: Bool

    @State private var model: SettingsScreenModel = .init()

    private let navigateToRoute: (IncomesRoute) -> Void
    private let subscriptionTip = SubscriptionTip()
    private let yearlyDuplicationTip = YearlyDuplicationTip()

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

        List { // swiftlint:disable:this closure_body_length
            subscriptionSection
            currencySection
            notificationSection(
                model: model
            )
            dataManagementSection(
                model: model
            )
            if model.hasDuplicateTags || model.hasOrphanTags {
                Section {
                    if model.hasDuplicateTags {
                        Button {
                            navigateToRoute(.duplicateTags)
                        } label: {
                            Text("Resolve duplicate tags")
                        }
                    }
                    if model.hasOrphanTags {
                        Button {
                            navigateToRoute(.orphanTags)
                        } label: {
                            Text("Review orphan tags")
                        }
                    }
                } header: {
                    HStack {
                        Text("Manage tags")
                        Circle()
                            .frame(width: .icon(.xs))
                            .foregroundStyle(.orange)
                    }
                }
            }
            if model.hasDebugData {
                Section {
                    Button(role: .destructive) {
                        Haptic.warning.impact()
                        model.presentDestructiveAction(.deleteDebugData)
                    } label: {
                        Text("Delete debug sample data")
                    }
                } header: {
                    HStack {
                        Text("Debug data")
                        Circle()
                            .frame(width: .icon(.xs))
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text("Removes debug sample items and their tags.")
                }
            }
            Section {
                Button("Show tips again") {
                    do {
                        try tipController.resetTips(hasAnyItems: !yearTags.isEmpty)
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
                routeRowButton(
                    "License",
                    route: .settingsLicense
                )
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(version) (\(build))")
                            .foregroundStyle(.secondary)
                    }
                    .contextMenu {
                        CopyTextContextMenuButton(
                            "Copy Version",
                            text: "\(version) (\(build))"
                        )
                    }
                }
            }
            ShortcutsLinkSection()
            if isDebugOn {
                Section {
                    routeRowButton(
                        "Debug",
                        route: .settingsDebug
                    )
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
                    do {
                        try await DataMaintenanceService.resetAllData(context: context)
                        Haptic.success.impact()
                        model.loadStatus(context: context)
                        model.dismissDestructiveAction()
                    } catch {
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
                    try DataMaintenanceService.deleteDebugData(context: context)
                    Haptic.success.impact()
                    model.loadStatus(context: context)
                    model.dismissDestructiveAction()
                } catch {
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
            model.loadStatus(context: context)
            await SettingsActionCoordinator.refreshNotifications(
                notificationService: notificationService
            )
            await notificationService.refreshAuthorizationStatus()
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
    var subscriptionSection: some View {
        Group {
            if isSubscribeOn {
                Section {
                    Toggle(isOn: $isICloudOn) {
                        Text("iCloud On")
                    }
                }
            } else {
                Section {
                    routeRowButton(
                        "Subscription",
                        route: .settingsSubscription
                    ) {
                        tipController.donateDidOpenSubscription()
                    }
                    .popoverTip(subscriptionTip, arrowEdge: .top)
                }
            }
        }
    }

    var currencySection: some View {
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

    @ViewBuilder
    func notificationSection(
        model: SettingsScreenModel
    ) -> some View {
        SettingsNotificationSection(
            notificationSettings: $notificationSettings,
            model: model,
            authorizationState: notificationService.authorizationState,
            sendTestNotification: {
                notificationService.sendTestNotification()
            },
            openSystemSettings: openSystemSettings
        )
    }

    @ViewBuilder
    func dataManagementSection(
        model: SettingsScreenModel
    ) -> some View {
        Section {
            yearlyDuplicationButton()
            Button(role: .destructive) {
                Haptic.warning.impact()
                model.presentDestructiveAction(.deleteAll)
            } label: {
                Text("Delete all")
            }
        } header: {
            Text("Manage items")
        }
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

    func routeRowButton(
        _ title: LocalizedStringKey,
        route: IncomesRoute,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            action?()
            navigateToRoute(route)
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func yearlyDuplicationButton() -> some View {
        let button = Button("Duplicate year items") {
            tipController.donateDidOpenYearlyDuplication()
            navigateToRoute(.yearlyDuplication)
        }

        if yearTags.isNotEmpty {
            button.popoverTip(yearlyDuplicationTip, arrowEdge: .top)
        } else {
            button
        }
    }

    func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}
