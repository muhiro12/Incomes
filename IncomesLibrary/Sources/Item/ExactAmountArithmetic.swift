import Foundation

/// Decimal addition and subtraction that refuse to lose digits.
///
/// Foundation can report success after discarding a small operand, for example
/// when `10^40 + 1` needs more mantissa digits than `Decimal` keeps. Every
/// result is therefore checked against Foundation's status and both inverse
/// relations, and an inexact, overflowing, or underflowing result is `nil`.
enum ExactAmountArithmetic {
    /// Returns `lhs + rhs`, or `nil` when the sum is not exact.
    static func sum(_ lhs: Decimal, _ rhs: Decimal) -> Decimal? {
        var lhs = lhs
        var rhs = rhs
        var result = Decimal.zero
        guard NSDecimalAdd(&result, &lhs, &rhs, .plain) == .noError,
              !result.isNaN,
              result - lhs == rhs,
              result - rhs == lhs else {
            return nil
        }
        return result
    }

    /// Returns `lhs - rhs`, or `nil` when the difference is not exact.
    static func difference(_ lhs: Decimal, _ rhs: Decimal) -> Decimal? {
        var lhs = lhs
        var rhs = rhs
        var result = Decimal.zero
        guard NSDecimalSubtract(&result, &lhs, &rhs, .plain) == .noError,
              !result.isNaN,
              result + rhs == lhs,
              lhs - result == rhs else {
            return nil
        }
        return result
    }

    /// Returns the exact total of `values`, or `nil` when any partial sum is not exact.
    static func total(_ values: some Sequence<Decimal>) -> Decimal? {
        var total = Decimal.zero
        for value in values {
            guard let nextTotal = sum(total, value) else {
                return nil
            }
            total = nextTotal
        }
        return total
    }

    /// Returns the exact total of `values`, throwing when it is not exact.
    static func checkedTotal(_ values: some Sequence<Decimal>) throws -> Decimal {
        guard let total = total(values) else {
            throw ItemAmountError.totalOutOfRange
        }
        return total
    }

    /// Returns `lhs - rhs`, throwing when the difference is not exact.
    static func checkedDifference(_ lhs: Decimal, _ rhs: Decimal) throws -> Decimal {
        guard let difference = difference(lhs, rhs) else {
            throw ItemAmountError.totalOutOfRange
        }
        return difference
    }
}
