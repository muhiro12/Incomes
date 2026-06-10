enum YearlyDuplicationIntentSupport {
    nonisolated static func requestMetadata(
        sourceYear: Int,
        targetYear: Int,
        includeSingleItems: Bool,
        minimumRepeatItemCount: Int,
        skipExistingItems: Bool
    ) -> [String: String] {
        IncomesLogging.metadata(
            ("source_year", String(sourceYear)),
            ("target_year", String(targetYear)),
            ("include_single_items", IncomesLogging.bool(includeSingleItems)),
            ("minimum_repeat_item_count", String(minimumRepeatItemCount)),
            ("skip_existing_items", IncomesLogging.bool(skipExistingItems))
        )
    }
}
