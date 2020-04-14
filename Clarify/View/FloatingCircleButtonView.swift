//
//  FloatingCircleButtonView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct FloatingCircleButtonView: View {
    let action: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: action) {
                    ZStack {
                        Circle().frame(width: .iconM, height: .iconM)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                    .frame(width: .spaceM)
            }
            Spacer()
                .frame(height: .spaceM)
        }
    }
}

struct FloatingCircleButtonView_Previews: PreviewProvider {
    static var testData = { print("debug") }

    static var previews: some View {
        FloatingCircleButtonView(action: testData)
    }
}
