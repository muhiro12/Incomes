import SwiftData
import SwiftUI

/// Keeps SwiftData observation while checking ownership against current Tag relationships.
@propertyWrapper
struct LedgerItemQuery: DynamicProperty {
    @Query private var candidates: [Item]
    private let descriptor: ItemFetchDescriptor

    var wrappedValue: [Item] {
        descriptor.results(from: candidates)
    }

    init(_ descriptor: ItemFetchDescriptor) {
        self.descriptor = descriptor
        _candidates = Query(descriptor.candidateDescriptor)
    }
}
