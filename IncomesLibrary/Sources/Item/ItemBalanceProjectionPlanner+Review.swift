import Foundation
import SwiftData

extension ItemBalanceProjectionPlanner {
    /// Inputs describing one proposed mutation to review.
    struct ReviewRequest {
        let target: ItemBalanceProjectionReview.Target
        let draft: ItemBalanceProjectionReview.Draft
        let changedRows: [ProjectedRow]
        let replacingItemIDs: Set<PersistentIdentifier>
        let affectedItems: [Item]
        let affectedDates: [Date]
    }

    static func review(
        context: ModelContext,
        request: ReviewRequest
    ) throws -> ItemBalanceProjectionReview {
        let existingItems = try context.fetch(
            .items(.all, order: .forward)
        )
        let plan = projectionPlan(
            existingItems: existingItems,
            request: request
        )
        return .init(
            target: request.target,
            draft: request.draft,
            baseline: baseline(
                plan: plan,
                affectedItems: request.affectedItems
            ),
            comparison: comparison(from: plan)
        )
    }
}

private extension ItemBalanceProjectionPlanner {
    /// Rows, ranges, and balances one review is calculated from.
    struct ProjectionPlan {
        let existingItems: [Item]
        let balancedExistingRows: [BalancedProjectedRow]
        let projectedRows: [ProjectedRow]
        let affectedDateRange: ClosedRange<Date>?
        let projectionDateRange: ClosedRange<Date>?
        let changedItemCount: Int
    }

    static func projectionPlan(
        existingItems: [Item],
        request: ReviewRequest
    ) -> ProjectionPlan {
        let existingRows = existingItems.map { item in
            projectedRow(item: item)
        }
        let unchangedRows = existingRows.filter { row in
            guard let itemID = row.itemID else {
                return true
            }
            return !request.replacingItemIDs.contains(itemID)
        }
        let projectedRows = sortedRows(unchangedRows + request.changedRows)
        let affectedDateRange = dateRange(from: request.affectedDates)
        return .init(
            existingItems: existingItems,
            balancedExistingRows: balancedRows(existingRows),
            projectedRows: projectedRows,
            affectedDateRange: affectedDateRange,
            projectionDateRange: projectedDateRange(
                rows: projectedRows,
                affectedDateRange: affectedDateRange
            ),
            changedItemCount: request.changedRows.count
        )
    }

    static func comparison(from plan: ProjectionPlan) -> Comparison {
        let current = projection(
            balancedRows: plan.balancedExistingRows,
            dateRange: plan.projectionDateRange,
            affectedDateRange: plan.affectedDateRange,
            changedItemCount: 0
        )
        let projected = projection(
            rows: plan.projectedRows,
            dateRange: plan.projectionDateRange,
            affectedDateRange: plan.affectedDateRange,
            changedItemCount: plan.changedItemCount
        )
        return .init(
            current: current,
            projected: projected,
            monthlyBalances: monthlyComparisons(
                current: current.monthlyBalances,
                projected: projected.monthlyBalances
            )
        )
    }

    static func baseline(
        plan: ProjectionPlan,
        affectedItems: [Item]
    ) -> ItemBalanceProjectionReview.Baseline {
        .init(
            startingBalance: startingBalance(
                from: plan.balancedExistingRows,
                dateRange: plan.projectionDateRange
            ) ?? .zero,
            records: recordSignatures(from: plan.existingItems),
            affectedRecords: recordSignatures(from: affectedItems)
        )
    }

    static func recordSignatures(
        from items: [Item]
    ) -> [ItemBalanceProjectionReview.RecordSignature] {
        items.map { item in
            ItemBalanceProjectionReview.RecordSignature(
                itemID: item.persistentModelID,
                repeatID: item.repeatID,
                utcDate: item.utcDate,
                content: item.content,
                category: item.category?.name ?? "",
                income: item.income,
                outgo: item.outgo,
                priority: item.priority
            )
        }
        .sorted { left, right in
            isOrderedBefore(left, right)
        }
    }

    static func isOrderedBefore(
        _ left: ItemBalanceProjectionReview.RecordSignature,
        _ right: ItemBalanceProjectionReview.RecordSignature
    ) -> Bool {
        if left.utcDate != right.utcDate {
            return left.utcDate < right.utcDate
        }
        if left.priority != right.priority {
            return left.priority > right.priority
        }
        if left.content != right.content {
            return left.content < right.content
        }
        return String(describing: left.itemID) < String(describing: right.itemID)
    }

    static func balancedRows(
        _ rows: [ProjectedRow]
    ) -> [BalancedProjectedRow] {
        let orderedRows = sortedRows(rows)
        let balances = BalanceCalculator.calculateBalances(
            startingFrom: .zero,
            inputs: orderedRows.map { row in
                .init(netIncome: row.netIncome)
            }
        )
        return zip(orderedRows, balances).map { row, balance in
            .init(
                row: row,
                balance: balance
            )
        }
    }

    static func projection(
        rows: [ProjectedRow],
        dateRange: ClosedRange<Date>?,
        affectedDateRange: ClosedRange<Date>?,
        changedItemCount: Int
    ) -> Projection {
        projection(
            balancedRows: balancedRows(rows),
            dateRange: dateRange,
            affectedDateRange: affectedDateRange,
            changedItemCount: changedItemCount
        )
    }

    static func projection(
        balancedRows: [BalancedProjectedRow],
        dateRange: ClosedRange<Date>?,
        affectedDateRange: ClosedRange<Date>?,
        changedItemCount: Int
    ) -> Projection {
        let rowsInRange = rows(
            from: balancedRows,
            dateRange: dateRange
        )
        let startingBalance = startingBalance(
            from: balancedRows,
            dateRange: dateRange
        )
        return .init(
            dateRange: dateRange,
            affectedDateRange: affectedDateRange,
            minimumBalance: minimumBalance(
                startingBalance: startingBalance,
                rowsInRange: rowsInRange
            ),
            firstNegativeDate: firstNegativeDate(
                startingBalance: startingBalance,
                rowsInRange: rowsInRange,
                dateRange: dateRange
            ),
            latestBalance: rowsInRange.last?.balance ?? startingBalance,
            monthlyBalances: monthlyBalances(
                from: balancedRows,
                dateRange: dateRange
            ),
            changedItemCount: changedItemCount
        )
    }

    static func minimumBalance(
        startingBalance: Decimal?,
        rowsInRange: [BalancedProjectedRow]
    ) -> Decimal? {
        let minimumRowBalance = rowsInRange.map(\.balance).min()
        guard let startingBalance else {
            return minimumRowBalance
        }
        guard let minimumRowBalance else {
            return startingBalance
        }
        guard startingBalance < .zero else {
            return minimumRowBalance
        }
        return min(startingBalance, minimumRowBalance)
    }

    static func projectedRow(item: Item) -> ProjectedRow {
        .init(
            itemID: item.persistentModelID,
            utcDate: item.utcDate,
            localDate: item.localDate,
            content: item.content,
            priority: item.priority,
            netIncome: item.netIncome,
            tieBreaker: String(describing: item.persistentModelID)
        )
    }
}
