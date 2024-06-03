//
//  RepeatCountPicker.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/06/03.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct RepeatCountPicker {
    @Binding private var selection: Int

    init(selection: Binding<Int>) {
        self._selection = selection
    }
}

extension RepeatCountPicker: View {
    var body: some View {
        HStack {
            Text("Repeat")
            Spacer()
            Picker("Repeat",
                   selection: $selection) {
                ForEach((.minRepeatCount)..<(.maxRepeatCount + .one), id: \.self) {
                    Text($0.description)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .frame(width: .componentS,
                   height: .componentS)
            .clipped()
        }
    }
}

#Preview {
    RepeatCountPicker(selection: .constant(.zero))
}
