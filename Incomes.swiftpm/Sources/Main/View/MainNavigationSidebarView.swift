//
//  MainSidebarView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/24.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct MainNavigationSidebarView {
    @Environment(TagService.self)
    private var tagService
    @Environment(NotificationService.self)
    private var notificationService

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Environment(\.pathSelection)
    private var selection

    @State private var isSettingsPresented = false
}

extension MainNavigationSidebarView: View {
    var body: some View {
        List(selection: selection) {
            Section {
                NavigationLink(path: .home) {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
                NavigationLink(path: .category) {
                    Label {
                        Text("Category")
                    } icon: {
                        Image(systemName: "square.stack.3d.up")
                    }
                }
            }
            if isDebugOn {
                NavigationLink(path: .debug) {
                    Label {
                        Text("Debug")
                    } icon: {
                        Image(systemName: "flask")
                    }
                }
            }
        }
        .navigationTitle(Text("Incomes"))
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
        MainNavigationSidebarView()
    }
}
