//
//  SidebarView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/24.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SidebarView {
    @Environment(\.scenePhase)
    private var scenePhase

    @Environment(TagService.self)
    private var tagService
    @Environment(NotificationService.self)
    private var notificationService

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Binding private var selection: SidebarItem.ID?

    @State private var isSettingsPresented = false
    @State private var isDebugPresented = false

    init(selection: Binding<SidebarItem.ID?>) {
        _selection = selection
    }
}

extension SidebarView: View {
    var body: some View {
        List(SidebarItem.allCases, selection: $selection) { sidebar in
            Label {
                Text(sidebar.title)
            } icon: {
                Image(systemName: sidebar.image)
            }
        }
        .toolbar {
            if isDebugOn {
                ToolbarItem {
                    Button {
                        isDebugPresented = true
                    } label: {
                        Image(systemName: "flask")
                    }
                }
            }
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
        .sheet(isPresented: $isDebugPresented) {
            DebugNavigationView()
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
        SidebarView(selection: .constant(nil))
    }
}
