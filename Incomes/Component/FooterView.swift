//
//  FooterView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct FooterView: View {
    @Environment(\.managedObjectContext) var context

    @Binding var scene: Scene

    @State private var isPresentedToEdit = false

    var body: some View {
        VStack {
            Divider()
            HStack {
                Button(action: toNextScene) {
                    Image(systemName: scene.isHome ? .groupIcon : .homeIcon)
                        .iconFrame()
                }
                Spacer()
                Text(verbatim: .footerTextPrefix + Date().yearAndMonthAndDay)
                    .font(.footnote)
                Spacer()
                Button(action: presentToEdit) {
                    Image(systemName: .createIcon)
                        .iconFrame()
                }
            }.padding(EdgeInsets(top: .spaceS,
                                 leading: .spaceM,
                                 bottom: .spaceS,
                                 trailing: .spaceM))
        }.sheet(isPresented: $isPresentedToEdit) {
            EditView()
                .environment(\.managedObjectContext, self.context)
        }
    }

    private func toNextScene() {
        self.scene.toNext()
    }

    private func presentToEdit() {
        isPresentedToEdit = true
    }
}

struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
        FooterView(scene: .constant(.home))
    }
}
