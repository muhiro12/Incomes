import SwiftUI
import TipKit

struct ItemDetailTip: Tip {
    var title: Text {
        Text("Inspect item details")
    }

    var message: Text? {
        Text("Tap an item to check its date, amounts, category, and actions.")
    }

    var image: Image? {
        Image(systemName: "doc.text.magnifyingglass")
    }

    var rules: [Rule] {
        #Rule(IncomesTipEvents.didOpenMonth) { event in
            event.donations.count > 0
        }
        #Rule(IncomesTipEvents.didOpenItemDetail) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
