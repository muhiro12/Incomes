//
//  SettingsListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import SwiftUtilities

struct SettingsListView {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService
    @Environment(NotificationService.self)
    private var notificationService

    @Environment(\.isPresented)
    private var isPresented

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.currencyCode)
    private var currencyCode

    @Binding private var path: IncomesPath?

    @State private var selectedCurrencyCode = CurrencyCode.system
    @State private var isDialogPresented = false
    @State private var isDuplicateTagPresented = false

    init(selection: Binding<IncomesPath?> = .constant(nil)) {
        _path = selection
    }
}

extension SettingsListView: View {
    var body: some View {
        List(selection: $path) {
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
                    isDialogPresented = true
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
                NavigationLink {
                    LicenseView()
                } label: {
                    Text("License")
                }
            }
            ShortcutsLinkSection()
        }
        .navigationTitle(Text("Settings"))
        .toolbar {
            if isPresented {
                ToolbarItem {
                    CloseButton()
                }
            }
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
        .confirmationDialog(
            Text("Delete all"),
            isPresented: $isDialogPresented
        ) {
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
        } message: {
            Text("Are you sure you want to delete all items?")
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
        NavigationStack {
            SettingsListView()
        }
    }
}
