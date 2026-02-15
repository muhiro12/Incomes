//
//  SettingsListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct SettingsListView {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService

    @Environment(\.locale)
    private var locale

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

    private let navigateToRoute: (IncomesRoute) -> Void

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
                routeRowButton(
                    "Subscription",
                    route: .settingsSubscription
                )
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
                Button("Duplicate year items") {
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
                        Text("Delete tutorial/debug data")
                    }
                } header: {
                    HStack {
                        Text("Debug data")
                        Circle()
                            .frame(width: .icon(.xs))
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text("Removes items tagged as Debug and their tags.")
                }
            }
            Section {
                Button("View App Introduction Again") {
                    navigateToRoute(.introduction)
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
            Text("Delete tutorial/debug data"),
            isPresented: $isDeleteDebugDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try SettingsActionCoordinator.deleteDebugData(context: context)
                    updateStatus()
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
            Text("This will remove tutorial/debug items and tags. Continue?")
        }
        .task {
            updateStatus()

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
        .onAppear {
            updateStatus()
        }
    }
}

private extension SettingsListView {
    func routeRowButton(
        _ title: LocalizedStringKey,
        route: IncomesRoute
    ) -> some View {
        Button {
            navigateToRoute(route)
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
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
