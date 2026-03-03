//
//  SettingsListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
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
        }
    ) {
        self.navigateToRoute = navigateToRoute
    }
}

extension SettingsListView: View {
    var body: some View {
        List {
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
            Section("Push notification settings") {
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
                        .frame(maxWidth: 120)
                    }
                    Picker("Notify days before", selection: $notificationSettings.daysBeforeDueDate) {
                        ForEach(0..<15) { dayOffset in
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
                    try SettingsActionCoordinator.deleteAllData(context: context)
                    updateStatus()
                    refreshTipEligibility()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
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
                    try SettingsActionCoordinator.deleteDebugData(context: context)
                    updateStatus()
                    refreshTipEligibility()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
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
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        SettingsListView()
    }
}
