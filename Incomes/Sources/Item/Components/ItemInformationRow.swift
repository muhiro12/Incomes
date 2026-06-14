import SwiftUI

struct ItemInformationRow<Value: View>: View {
    let title: LocalizedStringKey
    let value: Value

    init( // swiftlint:disable:this type_contents_order
        title: LocalizedStringKey,
        @ViewBuilder value: () -> Value
    ) {
        self.title = title
        self.value = value()
    }

    var body: some View {
        LabeledContent(title) {
            value
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
