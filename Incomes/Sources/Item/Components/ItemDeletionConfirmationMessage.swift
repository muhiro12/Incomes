import SwiftUI

struct ItemDeletionConfirmationMessage: View {
    let itemCount: Int

    var body: some View {
        if itemCount == 1 {
            Text("Are you sure you want to delete this item?")
        } else {
            Text("Are you sure you want to delete \(itemCount) items?")
        }
    }
}

#Preview {
    ItemDeletionConfirmationMessage(itemCount: 2)
}
