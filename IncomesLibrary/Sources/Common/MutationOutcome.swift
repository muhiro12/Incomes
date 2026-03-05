import Foundation
import SwiftData

/// Describes what changed after a domain mutation.
public struct MutationOutcome {
    /// Persistent model identifiers grouped by mutation kind.
    public struct ChangedIDs {
        /// Newly created models.
        public let created: Set<PersistentIdentifier>
        /// Updated models.
        public let updated: Set<PersistentIdentifier>
        /// Deleted models.
        public let deleted: Set<PersistentIdentifier>

        /// Creates identifier groups.
        public init(
            created: Set<PersistentIdentifier> = [],
            updated: Set<PersistentIdentifier> = [],
            deleted: Set<PersistentIdentifier> = []
        ) {
            self.created = created
            self.updated = updated
            self.deleted = deleted
        }
    }

    /// Suggested follow-up orchestration owned by adapters.
    public enum FollowUpHint: Hashable, Sendable {
        case refreshNotificationSchedule
        case reloadWidgets
        case refreshWatchSnapshot
    }

    /// IDs grouped by created/updated/deleted.
    public let changedIDs: ChangedIDs
    /// Inclusive date range potentially affected by the mutation.
    public let affectedDateRange: ClosedRange<Date>?
    /// Suggested adapter follow-up actions.
    public let followUpHints: Set<FollowUpHint>

    /// Creates a new mutation outcome value.
    public init(
        changedIDs: ChangedIDs,
        affectedDateRange: ClosedRange<Date>?,
        followUpHints: Set<FollowUpHint>
    ) {
        self.changedIDs = changedIDs
        self.affectedDateRange = affectedDateRange
        self.followUpHints = followUpHints
    }
}
