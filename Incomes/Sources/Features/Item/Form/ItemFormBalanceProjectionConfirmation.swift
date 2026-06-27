import Foundation

struct ItemFormBalanceProjectionConfirmation: Identifiable {
    enum Action {
        case create
        case update(ItemMutationScope)
    }

    let id = UUID()
    let action: Action
    let projection: ItemBalanceProjectionOperations.Projection

    var primaryActionTitle: String {
        switch action {
        case .create:
            "Create Anyway"
        case .update:
            "Save Anyway"
        }
    }

    var message: String {
        var lines = [String]()
        if let minimumBalance = projection.minimumBalance {
            lines.append("Minimum balance: \(minimumBalance.asCurrency)")
        }
        if let firstNegativeDate = projection.firstNegativeDate {
            lines.append("First negative date: \(Formatting.shortDayTitle(from: firstNegativeDate))")
        }
        if projection.changedItemCount > 1 {
            lines.append("Affected items: \(projection.changedItemCount)")
        }
        return lines.joined(separator: "\n")
    }
}
