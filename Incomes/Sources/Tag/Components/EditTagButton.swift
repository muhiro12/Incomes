//
//  EditTagButton.swift
//  Incomes
//
//  Created by Codex on 2025/07/07.
//

import SwiftUI

struct EditTagButton {
    @Environment(TagEntity.self)
    private var tag

    @State private var isPresented = false

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension EditTagButton: View {
    var body: some View {
        Button {
            if let action {
                action()
            } else {
                isPresented = true
            }
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .sheet(isPresented: $isPresented) {
            TagFormNavigationView(mode: .edit)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        EditTagButton()
            .environment(preview.tags[0])
    }
}
