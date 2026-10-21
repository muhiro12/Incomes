import Foundation
import SwiftData

/// Keeps file balances as explicit baselines, independently of import conflict decisions.
enum ItemImportBalancePlanner {
    struct Row {
        let item: IncomesFileItem
        let importedBalance: Decimal?
        let tieBreaker: String
    }

    static func affectedDates(
        difference: ItemImportDifference,
        plan: ItemImportPlan
    ) -> [LedgerIdentifier: Date] {
        let removed = difference.reviewedStoreItems.filter { item in
            plan.removedItemIDs.contains(item.id)
        }
        return Dictionary(grouping: plan.insertedItems + removed.map(\.item), by: \.ledgerIdentifier)
            .compactMapValues { items in
                items.map(\.localDate).min()
            }
    }

    static func rows(difference: ItemImportDifference, plan: ItemImportPlan) -> [Row] {
        let retained = difference.reviewedStoreItems
            .filter { item in
                !plan.removedItemIDs.contains(item.id)
            }
            .map { item in
                Row(
                    item: item.item,
                    importedBalance: plan.preservedBalanceItemIDs.contains(item.id) ? item.item.balance : nil,
                    tieBreaker: String(describing: item.id)
                )
            }
        let inserted = plan.insertedItems.enumerated().map { index, item in
            Row(item: item, importedBalance: item.balance, tieBreaker: "import.\(index)")
        }
        return (retained + inserted).sorted { left, right in
            if left.item.date != right.item.date {
                return left.item.date < right.item.date
            }
            if left.item.priority != right.item.priority {
                return left.item.priority > right.item.priority
            }
            if left.item.content != right.item.content {
                return left.item.content < right.item.content
            }
            return left.tieBreaker < right.tieBreaker
        }
    }

    static func balances(
        rows: [Row],
        affectedDates: [LedgerIdentifier: Date],
        policy: ItemImportBalancePolicy
    ) throws -> [Decimal] {
        var previousBalances: [LedgerIdentifier: Decimal] = [:]
        return try rows.map { row in
            let identifier = row.item.ledgerIdentifier
            let balance: Decimal
            let isAffected = affectedDates[identifier].map { row.item.localDate >= $0 } ?? false
            if isAffected {
                guard AmountPrecision.isExactlyStorable(row.item.income),
                      AmountPrecision.isExactlyStorable(row.item.outgo) else {
                    throw ItemAmountError.balanceOutOfRange
                }
                if policy == .preserveSavedBalances, let saved = row.importedBalance {
                    balance = saved
                } else {
                    let netIncome = try BalanceCalculator.netIncome(income: row.item.income, outgo: row.item.outgo)
                    guard let calculated = ExactAmountArithmetic.sum(
                        previousBalances[identifier] ?? .zero,
                        netIncome
                    ) else {
                        throw ItemAmountError.balanceOutOfRange
                    }
                    balance = calculated
                }
            } else {
                balance = row.item.balance ?? .zero
            }
            guard !isAffected || AmountPrecision.isExactlyStorable(balance) else {
                throw ItemAmountError.balanceOutOfRange
            }
            previousBalances[identifier] = balance
            return balance
        }
    }

    static func review(difference: ItemImportDifference, plan: ItemImportPlan) throws -> ItemImportBalanceReview {
        let rows = rows(difference: difference, plan: plan)
        let dates = affectedDates(difference: difference, plan: plan)
        let affectedRows = rows.filter { row in
            dates[row.item.ledgerIdentifier].map { row.item.localDate >= $0 } ?? false
        }
        let hasAmbiguousOrder = Set(affectedRows.map { IncomesFileOrderKey($0.item) }).count != affectedRows.count
        let preserved = try balances(rows: rows, affectedDates: dates, policy: .preserveSavedBalances)
        do {
            let recalculated = try balances(rows: rows, affectedDates: dates, policy: .recalculate)
            return .init(
                hasDifferences: preserved != recalculated,
                hasAmbiguousOrder: hasAmbiguousOrder,
                canRecalculate: true
            )
        } catch ItemAmountError.balanceOutOfRange {
            return .init(hasDifferences: true, hasAmbiguousOrder: hasAmbiguousOrder, canRecalculate: false)
        }
    }

    /// Use actual model order after insertion, including ties resolved by native identity.
    static func apply(
        items: [Item],
        importedBalances: [PersistentIdentifier: Decimal],
        affectedDates: [LedgerIdentifier: Date],
        policy: ItemImportBalancePolicy
    ) throws {
        let ordered = items.sorted(by: >)
        let rows = ordered.map { item in
            Row(
                item: .init(item: item, balance: item.balance),
                importedBalance: importedBalances[item.persistentModelID],
                tieBreaker: String(describing: item.persistentModelID)
            )
        }
        let balances = try balances(rows: rows, affectedDates: affectedDates, policy: policy)
        for (item, balance) in zip(ordered, balances) where item.balance != balance {
            item.modify(balance: balance)
        }
    }
}
