//
//  TagFormView.swift
//  Incomes
//
//  Created by Codex on 2025/07/07.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct TagFormView: View {
    enum Mode {
        case edit
    }

    @Environment(TagEntity.self)
    private var tag
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context

    @State private var name = String.empty

    let mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }

    var body: some View {
        Form {
            HStack {
                Text("Name")
                Spacer()
                TextField(String.empty, text: $name)
                    .multilineTextAlignment(.trailing)
            }
        }
        .navigationTitle(Text("Edit"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: dismiss.callAsFunction) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: save) {
                    Text("Save")
                }
                .bold()
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            name = tag.name
        }
    }
}

private extension TagFormView {
    func save() {
        do {
            try UpdateTagIntent.perform(
                (
                    context: context,
                    tag: tag,
                    name: name
                )
            )
            Haptic.success.impact()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            TagFormView(mode: .edit)
                .environment(preview.tags[0])
        }
    }
}
