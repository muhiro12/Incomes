import SwiftUI
import TipKit

struct CreateItemTip: Tip {
    @Parameter static var hasAnyItems: Bool = true

    var title: Text {
        Text("Create your first item")
    }

    var message: Text? {
        Text("Add one item to start tracking income, outgo, and balance.")
    }

    var image: Image? {
        Image(systemName: "square.and.pencil")
    }

    var rules: [Rule] {
        #Rule(Self.$hasAnyItems) { hasAnyItems in
            hasAnyItems == false
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
