import SwiftUI
import TipKit

struct CreateItemTip: Tip {
    @Parameter
    static var hasAnyItems: Bool = true

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
        #Rule(IncomesTipEvents.didOpenCreateForm) {
            $0.donations.count > 0
        }
        #Rule(IncomesTipEvents.didEnableRepeat) {
            $0.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

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
        #Rule(IncomesTipEvents.didOpenMonth) {
            $0.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

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
        #Rule(IncomesTipEvents.didOpenMonth) {
            $0.donations.count > 0
        }
        #Rule(IncomesTipEvents.didOpenItemDetail) {
            $0.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

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
        #Rule(IncomesTipEvents.didOpenSearch) {
            $0.donations.count > 0
        }
        #Rule(IncomesTipEvents.didApplySearch) {
            $0.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

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
        #Rule(IncomesTipEvents.didOpenSubscription) {
            $0.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

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
        #Rule(IncomesTipEvents.didOpenYearlyDuplication) {
            $0.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
