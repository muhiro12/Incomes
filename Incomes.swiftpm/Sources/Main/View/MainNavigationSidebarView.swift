//
//  MainSidebarView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/24.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct MainNavigationSidebarView {
    @Environment(\.scenePhase)
    private var scenePhase

    @Environment(TagService.self)
    private var tagService
    @Environment(NotificationService.self)
    private var notificationService

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Binding private var selection: MainSidebarItem?

    @State private var isSettingsPresented = false

    init(selection: Binding<MainSidebarItem?>) {
        _selection = selection
    }
}

extension MainNavigationSidebarView: View {
    var body: some View {
        List(selection: $selection) {
            Section {
                Label {
                    Text("Home")
                } icon: {
                    Image(systemName: "calendar")
                }
                .tag(MainSidebarItem.home)
                Label {
                    Text("Category")
                } icon: {
                    Image(systemName: "square.stack.3d.up")
                }
                .tag(MainSidebarItem.category)
            }
            if isDebugOn {
                Label {
                    Text("Debug")
                } icon: {
                    Image(systemName: "flask")
                }
                .tag(MainSidebarItem.debug)
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isSettingsPresented = true
                } label: {
                    Image.settings
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .frame(width: .iconS)
                                .foregroundStyle(
                                    { () -> Color in
                                        if notificationService.hasNotification {
                                            .red
                                        } else if tagService.hasDuplicates {
                                            .orange
                                        } else {
                                            .clear
                                        }
                                    }()
                                )
                        }
                }
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsNavigationView()
        }
        .navigationTitle(Text("Incomes"))
        .onChange(of: scenePhase) {
            guard scenePhase == .active else {
                return
            }
            try? tagService.updateHasDuplicates()
            Task {
                await notificationService.update()
            }
        }
        .onChange(of: notificationService.shouldShowNotification) {
            guard notificationService.shouldShowNotification else {
                return
            }
            isSettingsPresented = true
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationSidebarView(selection: .constant(nil))
    }
}
