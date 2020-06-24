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

    @State private var isPresentingItemEditView = false

    var body: some View {
        VStack {
            Divider()
            Spacer()
                .frame(height: .spaceM)
            HStack {
                Spacer()
                    .frame(width: .spaceM)
                Button(action: toNextScene) {
                    Image(systemName: scene.isHome ? .groupIcon : .homeIcon)
                        .iconFrame()
                }
                Spacer()
                Button(action: presentItemEdit) {
                    Image(systemName: .createIcon)
                        .iconFrame()
                }
                Spacer()
                    .frame(width: .spaceM)
            }
            Spacer()
                .frame(height: .spaceS)
        }.sheet(isPresented: $isPresentingItemEditView) {
            ItemEditView()
                .environment(\.managedObjectContext, self.context)
        }
    }

    private func toNextScene() {
        self.scene.toNext()
    }

    private func presentItemEdit() {
        isPresentingItemEditView = true
    }
}

struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
        FooterView(scene: .constant(.home))
    }
}
