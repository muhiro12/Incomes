enum TagIntentEntitySupport {
    static func entities(from tags: [Tag]) throws -> [TagEntity] {
        try tags.map { tag in
            try TagEntity.make(from: tag)
        }
    }
}
