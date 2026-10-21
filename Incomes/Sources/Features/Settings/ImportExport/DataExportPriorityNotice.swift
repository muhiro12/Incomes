import Foundation

/// Shared disclosure for the file-only priority changes made by export.
enum DataExportPriorityNotice {
    static func message(for preparation: ItemExportPreparation) -> String? {
        message(
            hasAdjustedPriorities: preparation.adjustedPriorityCount > .zero,
            hasUnresolvedOrder: preparation.unresolvedDayCount > .zero
        )
    }

    static func message(hasAdjustedPriorities: Bool, hasUnresolvedOrder: Bool) -> String? {
        if hasUnresolvedOrder, hasAdjustedPriorities {
            return String(
                localized: """
                    Priorities change only in this copy. Some tied items may still change order and balances on \
                    restore.
                    """
            )
        }
        if hasUnresolvedOrder {
            return String(
                localized: """
                    Some tied items may change order and displayed balances on restore. Current data stays \
                    unchanged.
                    """
            )
        }
        if hasAdjustedPriorities {
            return String(
                localized: "File priorities are adjusted to preserve restore order. Your current data stays unchanged."
            )
        }
        return nil
    }
}
