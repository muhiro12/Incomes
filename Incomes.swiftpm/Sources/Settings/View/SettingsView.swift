//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUI
import SwiftUtilities

struct SettingsView {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService
    @Environment(NotificationService.self)
    private var notificationService

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.currencyCode)
    private var currencyCode

    @State private var selectedCurrencyCode = CurrencyCode.system
    @State private var isAlertPresented = false
    @State private var isDuplicateTagPresented = false
}

extension SettingsView: View {
    var body: some View {
        List {
            if isSubscribeOn {
                Toggle(isOn: $isICloudOn) {
                    Text("iCloud On")
                }
            } else {
                StoreSection()
            }
            Section {
                Picker(selection: $selectedCurrencyCode) {
                    ForEach(CurrencyCode.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                } label: {
                    Text("Currency Code")
                }
            }
            Section {
                Button {
                    do {
                        try itemService.recalculate()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                } label: {
                    Text("Recalculate")
                }
                Button(role: .destructive) {
                    isAlertPresented = true
                } label: {
                    Text("Delete all")
                }
            } header: {
                Text("Manage items")
            }
            if tagService.hasDuplicates {
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
                NavigationLink(path: .license) {
                    Text("License")
                }
            }
            Section {
                HStack {
                    Spacer()
                    ShortcutsLink()
                        .shortcutsLinkStyle(.automaticOutline)
                    Spacer()
                }
                .listRowBackground(EmptyView())
            }
        }
        .navigationTitle(Text("Settings"))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .alert(Text("Are you sure you want to delete all items?"),
               isPresented: $isAlertPresented) {
            Button(role: .destructive) {
                do {
                    try itemService.deleteAll()
                    try tagService.deleteAll()
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
        }
        .fullScreenCover(isPresented: $isDuplicateTagPresented) {
            DuplicateTagNavigationView()
        }
        .task {
            notificationService.refresh()
            selectedCurrencyCode = .init(rawValue: currencyCode) ?? .system
            try? tagService.updateHasDuplicates()
        }
        .onChange(of: selectedCurrencyCode) {
            currencyCode = selectedCurrencyCode.rawValue
        }
    }
}

#Preview {
    IncomesPreview { _ in
        SettingsView()
    }
}
