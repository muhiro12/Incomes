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
        List(isSubscribeOn ? subscriber : user, selection: $selection) {
            Label(.init($0.title.key),
                  systemImage: $0.image)
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    isSettingsPresented = true
                }, label: {
                    Image.settings
                        .overlay(alignment: .topTrailing) {
                            if notificationService.hasNotification {
                                Circle()
                                    .frame(width: .iconS)
                                    .foregroundStyle(.red)
                            }
                        }
                })
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsNavigationView()
        }
        .navigationTitle("Incomes")
        .onChange(of: scenePhase) {
            guard scenePhase == .active else {
                return
            }
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
    SidebarView(selection: .constant(nil))
        .previewNavigation()
}
