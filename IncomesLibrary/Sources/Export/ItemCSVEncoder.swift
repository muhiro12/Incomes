import Foundation

/// Spreadsheet-oriented representation, not a lossless store backup.
enum ItemCSVEncoder {
    static func encode(records: [ItemExportRecord], currencyCode: String) -> Data {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.calendar = .utc
        formatter.timeZone = .init(secondsFromGMT: .zero)
        formatter.dateFormat = "yyyy-MM-dd"

        var result = "\u{FEFF}date,content,income,outgo,balance,currency,category,priority,repeat_id\r\n"
        for record in records {
            let fields = [
                formatter.string(from: record.date),
                spreadsheetText(record.content),
                decimalString(record.income),
                decimalString(record.outgo),
                decimalString(record.balance),
                spreadsheetText(currencyCode),
                spreadsheetText(record.category),
                String(record.priority),
                record.repeatID.uuidString
            ]
            result += fields.map(quotedField).joined(separator: ",") + "\r\n"
        }
        return Data(result.utf8)
    }
}

private extension ItemCSVEncoder {
    static func decimalString(_ value: Decimal) -> String {
        var value = value
        return NSDecimalString(&value, Locale(identifier: "en_US_POSIX"))
    }

    static func spreadsheetText(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasControlPrefix = value.first == "\t" || value.first == "\r" || value.first == "\n"
        if hasControlPrefix || trimmed.first.map({ "=+-@".contains($0) }) == true {
            return "'" + value
        }
        return value
    }

    static func quotedField(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
