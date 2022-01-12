//
//  IncomesFooter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct IncomesFooter: View {
    @Environment(\.managedObjectContext) var context

    @Binding var isHome: Bool

    @State private var isPresentedToEdit = false

    var body: some View {
        VStack {
            Divider()
            HStack {
                Button(action: toNextView) {
                    (isHome ? Image.group : Image.home)
                        .iconFrameM()
                }
                Spacer()
                Text(.localized(.footerTextPrefix) + Date().stringValue(.yyyyMMMd))
                    .font(.footnote)
                Spacer()
                Button(action: presentToEdit) {
                    Image.create
                        .iconFrameM()
                }
            }.padding(EdgeInsets(top: .spaceS,
                                 leading: .spaceM,
                                 bottom: .spaceS,
                                 trailing: .spaceM))
        }.sheet(isPresented: $isPresentedToEdit) {
            EditView()
                .environment(\.managedObjectContext, context)
        }
    }
}

// MARK: - private

private extension IncomesFooter {
    func toNextView() {
        isHome.toggle()
    }

    func presentToEdit() {
        isPresentedToEdit = true
    }
}

#if DEBUG
struct IncomesFooter_Previews: PreviewProvider {
    static var previews: some View {
        IncomesFooter(isHome: .constant(true))
    }
}
#endif
