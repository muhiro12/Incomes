//
//  SettingsListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//

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

    @Environment(\.locale)
    private var locale
    @Environment(\.scenePhase)
    private var scenePhase

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.currencyCode)
    private var currencyCode
    @AppStorage(.notificationSettings)
    private var notificationSettings
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isNotificationEnabled = true
    @State private var isDeleteDialogPresented = false
    @State private var isDeleteDebugDialogPresented = false
    @State private var hasDuplicateTags = false
    @State private var hasDebugData = false
    @State private var isSubscriptionTipEligible = false
    @State private var isYearlyDuplicationTipEligible = false

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
        List { // swiftlint:disable:this closure_body_length
            if isSubscribeOn {
                Toggle(isOn: $isICloudOn) {
                    Text("iCloud On")
                }
            } else {
                if isSubscriptionTipEligible {
                    TipView(subscriptionTip)
                }
                routeRowButton(
                    "Subscription",
                    route: .settingsSubscription
                ) {
                    tipController.donateDidOpenSubscription()
                }
            }
            Section {
                Picker(selection: $currencyCode) {
                    ForEach(CurrencyCode.allCases, id: \.rawValue) { code in
                        Text(code.displayName)
                    }
                } label: {
                    Text("Currency Code")
                }
            }
            Section("Push notification settings") { // swiftlint:disable:this closure_body_length
                Toggle("Enable push notifications", isOn: $notificationSettings.isEnabled)
                if isNotificationEnabled {
                    HStack {
                        Text("Notify for amounts over")
                        Spacer()
                        TextField(
                            "Amount",
                            value: $notificationSettings.thresholdAmount,
                            format: .currency(code: locale.currency?.identifier ?? .empty)
                        )
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120) // swiftlint:disable:this no_magic_numbers
                    }
                    Picker("Notify days before", selection: $notificationSettings.daysBeforeDueDate) {
                        ForEach(0..<15) { dayOffset in // swiftlint:disable:this no_magic_numbers
                            Text("\(dayOffset) days")
                        }
                    }
                    DatePicker(
                        "Notify time",
                        selection: $notificationSettings.notifyTime,
                        displayedComponents: .hourAndMinute
                    )
                    Button("Send test notification") {
                        notificationService.sendTestNotification()
                    }
                }
                switch notificationService.authorizationState {
                case .authorized:
                    Text("Notifications are enabled and will follow your in-app schedule.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                case .denied:
                    Button("Open System Settings") {
                        openSystemSettings()
                    }
                    Text("Notifications are currently denied in iOS Settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                case .notDetermined:
                    Text("Notification permission will be requested when reminders are registered.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                if shouldShowYearlyDuplicationTip {
                    TipView(yearlyDuplicationTip)
                }
                Button("Duplicate year items") {
                    tipController.donateDidOpenYearlyDuplication()
                    navigateToRoute(.yearlyDuplication)
                }
                Button(role: .destructive) {
                    Haptic.warning.impact()
                    isDeleteDialogPresented = true
                } label: {
                    Text("Delete all")
                }
            } header: {
                Text("Manage items")
            }
            if hasDuplicateTags {
                Section {
                    Button {
                        navigateToRoute(.duplicateTags)
                    } label: {
                        Text("Resolve duplicate tags")
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
            if hasDebugData {
                Section {
                    Button(role: .destructive) {
                        Haptic.warning.impact()
                        isDeleteDebugDialogPresented = true
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
                        refreshTipEligibility()
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
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try DataMaintenanceService.deleteAllData(context: context)
                    Haptic.success.impact()
                    updateStatus()
                    refreshTipEligibility()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete all items?")
        }
        .confirmationDialog(
            Text("Delete debug sample data"),
            isPresented: $isDeleteDebugDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try DataMaintenanceService.deleteDebugData(context: context)
                    Haptic.success.impact()
                    updateStatus()
                    refreshTipEligibility()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("This will remove debug sample items and tags. Continue?")
        }
        .task {
            updateStatus()
            refreshTipEligibility()

            isNotificationEnabled = notificationSettings.isEnabled

            await SettingsActionCoordinator.refreshNotifications(
                notificationService: notificationService
            )
        }
        .onChange(of: notificationSettings) {
            withAnimation {
                isNotificationEnabled = notificationSettings.isEnabled
            }

            Task {
                await SettingsActionCoordinator.refreshNotifications(
                    notificationService: notificationService
                )
            }
        }
        .onChange(of: yearTags) {
            refreshTipEligibility()
        }
        .onAppear {
            updateStatus()
            refreshTipEligibility()
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
    var shouldShowYearlyDuplicationTip: Bool {
        yearTags.isNotEmpty &&
            isSubscriptionTipEligible == false &&
            isYearlyDuplicationTipEligible
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

    func refreshTipEligibility() {
        isSubscriptionTipEligible = subscriptionTip.shouldDisplay
        isYearlyDuplicationTipEligible = yearlyDuplicationTip.shouldDisplay
    }

    func updateStatus() {
        do {
            let status = try SettingsActionCoordinator.loadStatus(context: context)
            hasDuplicateTags = status.hasDuplicateTags
            hasDebugData = status.hasDebugData
        } catch {
            assertionFailure(error.localizedDescription)
            hasDuplicateTags = false
            hasDebugData = false
        }
    }

    func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        SettingsListView()
    }
}
