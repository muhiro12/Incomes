//
//  SidebarView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/24.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SidebarView {
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
                })
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsNavigationView()
        }
        .navigationTitle("Incomes")
    }
}

#Preview {
    NavigationStackPreview {
        SidebarView(selection: .constant(nil))
    }
}
