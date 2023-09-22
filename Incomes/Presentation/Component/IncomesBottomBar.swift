//
//  IncomesBottomBar.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct IncomesBottomBar {
    @Environment(\.modelContext)
    private var context

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Binding private var path: NavigationPath
    @Binding private var isHome: Bool

    @State private var isPresentedToEdit = false

    init(path: Binding<NavigationPath>, isHome: Binding<Bool>) {
        _path = path
        _isHome = isHome
    }
}

extension IncomesBottomBar: View {
    var body: some View {
        Box()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        if isSubscribeOn {
                            Button(action: {
                                path = .init()
                                isHome.toggle()
                            }, label: {
                                (isHome ? Image.group : Image.home)
                                    .iconFrameM()
                            })
                        } else {
                            Box(width: .iconM,
                                height: .iconM)
                        }
                        Spacer()
                        Text(.localized(.footerTextPrefix) + Date().stringValue(.yyyyMMMd))
                            .font(.footnote)
                        Spacer()
                        Button(action: {
                            isPresentedToEdit = true
                        }, label: {
                            Image.create
                                .iconFrameM()
                        })
                    }
                }
            }
            .sheet(isPresented: $isPresentedToEdit) {
                ItemCreateView()
                    .environment(\.modelContext, context)
            }
    }
}

#Preview {
    NavigationStack {
        IncomesBottomBar(path: .constant(.init()), isHome: .constant(true))
    }
}
