import Foundation

/// Uses existing priorities to encode only otherwise ambiguous native ordering.
enum ItemExportPriorityPlanner {
    private struct Day: Hashable {
        let ledgerIdentifier: LedgerIdentifier
        let date: Date
    }

    /// Input follows the source's actual chronological order, including native identity ties.
    static func prepare(_ items: [IncomesFileItem]) -> ItemExportPreparation {
        let days = Dictionary(grouping: items.indices) { index in
            Day(ledgerIdentifier: items[index].ledgerIdentifier, date: items[index].date)
        }
        var result = items
        var adjustedCount = 0
        var unresolvedDays = 0
        for indices in days.values {
            let dayItems = indices.map { items[$0] }
            guard Set(dayItems.map(IncomesFileOrderKey.init)).count != dayItems.count else {
                continue
            }
            let priorities = priorities(for: dayItems)
            guard !priorities.isEmpty else {
                unresolvedDays += 1
                continue
            }
            for (index, priority) in zip(indices, priorities) where items[index].priority != priority {
                result[index] = items[index].replacing(priority: priority)
                adjustedCount += 1
            }
        }
        return .init(
            items: IncomesFileItem.sortedByValue(result),
            adjustedPriorityCount: adjustedCount,
            unresolvedDayCount: unresolvedDays
        )
    }
}

private extension ItemExportPriorityPlanner {
    /// An empty result means this nonempty day cannot fit within the editor's priority range.
    static func priorities(for items: [IncomesFileItem]) -> [Int] {
        let range = ItemFormInput.priorityRange
        var lowerBounds = Array(repeating: range.lowerBound, count: items.count)
        // Equal or descending descriptions need a priority step; ascending descriptions can share one.
        for index in items.indices.dropLast().reversed() {
            let step = items[index].content < items[index + 1].content ? 0 : 1
            lowerBounds[index] = lowerBounds[index + 1] + step
        }
        guard let firstLowerBound = lowerBounds.first, firstLowerBound <= range.upperBound else {
            return []
        }
        var result = [Int]()
        for index in items.indices {
            let upperBound: Int
            if let previous = result.last {
                let step = items[index - 1].content < items[index].content ? 0 : 1
                upperBound = previous - step
            } else {
                upperBound = range.upperBound
            }
            result.append(min(upperBound, max(lowerBounds[index], items[index].priority)))
        }
        return result
    }
}
