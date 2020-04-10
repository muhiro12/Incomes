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
                        Circle().frame(width: 44, height: 44)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                    .frame(width: 8)
            }
            Spacer()
                .frame(height: 8)
        }
    }
}

struct FloatingCircleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingCircleButtonView {
            print("debug")
        }
    }
}
