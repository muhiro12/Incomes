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

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Binding private var selection: SidebarItem.ID?

    @State private var isSettingsPresented = false

    private let user: [SidebarItem] = [.home]
    private let subscriber: [SidebarItem] = [.home,
                                             .category]

    init(selection: Binding<SidebarItem.ID?>) {
        _selection = selection
    }
}

extension SidebarView: View {
    var body: some View {
        List(isSubscribeOn ? subscriber : user, selection: $selection) { sidebar in
            Label {
                Text(sidebar.title)
            } icon: {
                Image(systemName: sidebar.image)
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
        SidebarView(selection: .constant(nil))
    }
}
