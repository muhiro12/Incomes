import SwiftData

extension ModelContext {
    /// Fetches the first model matching the given descriptor.
    func fetchFirst<T>(_ descriptor: FetchDescriptor<T>) throws -> T? where T: PersistentModel {
        var descriptor = descriptor
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }
}
