import Foundation

/// Read-only selection and snapshotting for spreadsheet export.
public enum ItemExportOperations {
    /// Returns the full data extent using the same day convention as Item.localDate.
    public static func overview(
        items: [Item],
        calendar: Calendar = .current
    ) -> ItemExportOverview {
        let dates = items.map(\.utcDate)
        return .init(
            totalCount: items.count,
            firstDate: dates.min().map { date in
                calendar.shiftedDate(componentsFrom: date, in: .utc)
            },
            lastDate: dates.max().map { date in
                calendar.shiftedDate(componentsFrom: date, in: .utc)
            }
        )
    }

    /// Counts records on both selected boundary days; reversed ranges contain none.
    public static func selectedCount(
        items: [Item],
        from startDate: Date,
        through endDate: Date,
        calendar: Calendar = .current
    ) -> Int {
        selectedItems(items: items, from: startDate, through: endDate, calendar: calendar).count
    }

    /// Captures values without changing models, balances, or related tags.
    public static func records(
        items: [Item],
        from startDate: Date,
        through endDate: Date,
        calendar: Calendar = .current
    ) -> [ItemExportRecord] {
        selectedItems(items: items, from: startDate, through: endDate, calendar: calendar)
            .sorted(by: >)
            .map { item in
                .init(
                    date: item.utcDate,
                    content: item.content,
                    income: item.income,
                    outgo: item.outgo,
                    balance: item.balance,
                    category: item.category?.name ?? "",
                    priority: item.priority,
                    repeatID: item.repeatID
                )
            }
    }

    /// Creates UTF-8 CSV with a BOM and CRLF rows; safe to run away from the model actor.
    public static func csvData(records: [ItemExportRecord], currencyCode: String) -> Data {
        ItemCSVEncoder.encode(records: records, currencyCode: currencyCode)
    }
}

private extension ItemExportOperations {
    static func selectedItems(
        items: [Item],
        from startDate: Date,
        through endDate: Date,
        calendar: Calendar
    ) -> [Item] {
        let firstDay = Calendar.utc.startOfDay(
            for: Calendar.utc.shiftedDate(componentsFrom: startDate, in: calendar)
        )
        let lastDay = Calendar.utc.startOfDay(
            for: Calendar.utc.shiftedDate(componentsFrom: endDate, in: calendar)
        )
        guard firstDay <= lastDay else {
            return []
        }
        return items.filter { item in
            item.utcDate >= firstDay && item.utcDate <= lastDay
        }
    }
}
