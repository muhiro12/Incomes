//
//  RepeatCountPicker.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/06/03.
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
            Picker(selection: $selection) {
                ForEach(1...60, id: \.self) { count in
                    Text(count.description)
                }
            } label: {
                Text("Repeat")
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .frame(
                width: .component(.s),
                height: .component(.s)
            )
            .clipped()
        }
    }
}

#Preview {
    RepeatCountPicker(selection: .constant(.zero))
}
