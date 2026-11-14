import SwiftData

/// Uses native identity for saved rows and request order for rows not yet inserted.
/// Planned rows follow saved rows; their final native identity is assigned on insertion.
enum ItemOrderTieBreaker: Comparable {
    case stored(PersistentIdentifier)
    case planned(Int)
}
