import SwiftUI
import TipKit

struct SearchFiltersTip: Tip {
    var title: Text {
        Text("Filter your search")
    }

    var message: Text? {
        Text("Use tags or amount ranges to narrow the results before opening items.")
    }

    var image: Image? {
        Image(systemName: "line.3.horizontal.decrease.circle")
    }

    var rules: [Rule] {
        #Rule(IncomesTipEvents.didOpenSearch) { event in
            event.donations.count > 0
        }
        #Rule(IncomesTipEvents.didApplySearch) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
