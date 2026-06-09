enum ItemIntentEntitySupport {
    static func entity(from item: Item?) throws -> ItemEntity? {
        guard let item else {
            return nil
        }
        return try ItemEntity.make(from: item)
    }

    static func entities(from items: [Item]) throws -> [ItemEntity] {
        try items.map { item in
            try ItemEntity.make(from: item)
        }
    }
}
