//
//  IncomesFooter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct IncomesFooter: View {
    @Environment(\.modelContext)
    private var context

    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    @Binding
    private var isHome: Bool

    @State
    private var isPresentedToEdit = false

    init(isHome: Binding<Bool>) {
        _isHome = isHome
    }

    var body: some View {
        VStack {
            Divider()
            HStack {
                if isSubscribeOn {
                    Button(action: {
                        isHome.toggle()
                    }, label: {
                        (isHome ? Image.group : Image.home)
                            .iconFrameM()
                    })
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
            }.padding(EdgeInsets(top: .spaceS,
                                 leading: .spaceM,
                                 bottom: .spaceS,
                                 trailing: .spaceM))
        }.sheet(isPresented: $isPresentedToEdit) {
            EditView()
                .environment(\.modelContext, context)
        }
    }
}

#Preview {
    IncomesFooter(isHome: .constant(true))
}
