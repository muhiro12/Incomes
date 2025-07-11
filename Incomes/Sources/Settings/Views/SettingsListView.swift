//
//  SettingsListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct SettingsListView {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService

    @Environment(\.locale)
    private var locale
    @Environment(\.isPresented)
    private var isPresented

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.currencyCode)
    private var currencyCode
    @AppStorage(.notificationSettings)
    private var notificationSettings

    @Binding private var tag: TagEntity?

    @State private var isNotificationEnabled = true
    @State private var isIntroductionPresented = false
    @State private var isDeleteDialogPresented = false
    @State private var isDuplicateTagPresented = false
    @State private var hasDuplicateTags = false

    init(selection: Binding<TagEntity?> = .constant(nil)) {
        _tag = selection
    }
}

extension SettingsListView: View {
    var body: some View {
        List(selection: $tag) {
            if isSubscribeOn {
                Toggle(isOn: $isICloudOn) {
                    Text("iCloud On")
                }
            } else {
                NavigationLink {
                    StoreListView()
                } label: {
                    Text("Subscription")
                }
            }
            Section {
                Picker(selection: $currencyCode) {
                    ForEach(CurrencyCode.allCases, id: \.rawValue) {
                        Text($0.displayName)
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
                        ForEach(0..<15) { Text("\($0) days") }
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
                RecalculateButton()
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
                        isDuplicateTagPresented = true
                    } label: {
                        Text("Resolve duplicate tags")
                    }
                } header: {
                    HStack {
                        Text("Manage tags")
                        Circle()
                            .frame(width: .iconS)
                            .foregroundStyle(.orange)
                    }
                }
            }
            Section {
                Button("View App Introduction Again") {
                    isIntroductionPresented = true
                }
                NavigationLink {
                    LicenseView()
                } label: {
                    Text("License")
                }
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
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Text("Settings"))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .sheet(isPresented: $isIntroductionPresented) {
            IntroductionNavigationView()
        }
        .confirmationDialog(
            Text("Delete all"),
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try DeleteAllItemsIntent.perform(context)
                    try DeleteAllTagsIntent.perform(context)
                    Haptic.success.impact()
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
        .fullScreenCover(isPresented: $isDuplicateTagPresented) {
            DuplicateTagNavigationView()
        }
        .task {
            do {
                hasDuplicateTags = try GetHasDuplicateTagsIntent.perform(context)
            } catch {
                assertionFailure(error.localizedDescription)
                hasDuplicateTags = false
            }

            isNotificationEnabled = notificationSettings.isEnabled

            notificationService.refresh()
            await notificationService.register()
        }
        .onChange(of: notificationSettings) {
            withAnimation {
                isNotificationEnabled = notificationSettings.isEnabled
            }

            Task {
                notificationService.refresh()
                await notificationService.register()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            SettingsListView()
        }
    }
}
