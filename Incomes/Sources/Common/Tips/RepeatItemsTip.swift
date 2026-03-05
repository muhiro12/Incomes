import SwiftUI
import TipKit

struct RepeatItemsTip: Tip {
    var title: Text {
        Text("Repeat recurring items")
    }

    var message: Text? {
        Text("Turn this on for rent, salary, and other entries you reuse every month.")
    }

    var image: Image? {
        Image(systemName: "repeat")
    }

    var rules: [Rule] {
        #Rule(IncomesTipEvents.didOpenCreateForm) { event in
            event.donations.count > 0
        }
        #Rule(IncomesTipEvents.didEnableRepeat) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
