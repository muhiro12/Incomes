import SwiftUI

struct ItemInformationRow<Value: View>: View {
    let title: LocalizedStringKey
    let value: Value

    init(
        title: LocalizedStringKey,
        @ViewBuilder value: () -> Value
    ) {
        self.title = title
        self.value = value()
    }
}

extension ItemInformationRow {
    @ViewBuilder var body: some View {
        LabeledContent(title) {
            value
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
