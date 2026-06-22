import SwiftUI
import TipKit

struct SubscriptionTip: Tip {
    var title: Text {
        Text("Explore Premium")
    }

    var message: Text? {
        Text("Open Subscription to unlock iCloud sync and remove ads across the app.")
    }

    var image: Image? {
        Image(systemName: "star.circle")
    }

    var rules: [Rule] {
        #Rule(IncomesTipEvents.didOpenSubscription) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
