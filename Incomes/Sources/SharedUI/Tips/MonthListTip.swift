import SwiftUI
import TipKit

struct MonthListTip: Tip {
    var title: Text {
        Text("Open a month")
    }

    var message: Text? {
        Text("Select a month row to review the items recorded in that month.")
    }

    var image: Image? {
        Image(systemName: "calendar")
    }

    var rules: [Rule] {
        #Rule(IncomesTipEvents.didOpenMonth) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
