/// Generic mutation result with the domain value and its outcome metadata.
public struct MutationResult<Value> {
    /// Primary value returned by the domain service.
    public let value: Value
    /// Mutation metadata for adapter orchestration.
    public let outcome: MutationOutcome

    /// Creates a mutation result.
    public init(value: Value, outcome: MutationOutcome) {
        self.value = value
        self.outcome = outcome
    }
}
