import SwiftUI
import TipKit

struct YearlyDuplicationTip: Tip {
    var title: Text {
        Text("Duplicate recurring yearly items")
    }

    var message: Text? {
        Text("Review repeated yearly entries and create the next year's set faster.")
    }

    var image: Image? {
        Image(systemName: "document.on.document")
    }

    var rules: [Rule] {
        #Rule(IncomesTipEvents.didOpenYearlyDuplication) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
