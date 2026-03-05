import Foundation

public struct YearlyItemDuplicationGroupAmount: Hashable {
    public let income: Decimal
    public let outgo: Decimal

    public init(income: Decimal, outgo: Decimal) {
        self.income = income
        self.outgo = outgo
    }
}
