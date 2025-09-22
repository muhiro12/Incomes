import Foundation

struct PhoneItem: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let date: Date
    let net: String
    let income: Decimal
    let outgo: Decimal
    let category: String
}
