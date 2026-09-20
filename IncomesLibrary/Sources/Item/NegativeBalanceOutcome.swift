import Foundation

/// Whether a proposed change causes a negative balance, or meets an existing one.
public enum NegativeBalanceOutcome: Equatable, Sendable {
    /// The covered range stays non-negative.
    case staysNonNegative
    /// The covered range only goes negative after the proposed change.
    case newlyNegative(date: Date)
    /// The plan already goes negative, and the change moves that date earlier.
    case earlierNegative(date: Date, currentDate: Date)
    /// The plan already goes negative on or before the same date.
    case alreadyNegative(date: Date)

    /// First date the projected balance is negative, when there is one.
    public var date: Date? {
        switch self {
        case .staysNonNegative:
            nil
        case .newlyNegative(let date),
             .earlierNegative(let date, _),
             .alreadyNegative(let date):
            date
        }
    }
}
