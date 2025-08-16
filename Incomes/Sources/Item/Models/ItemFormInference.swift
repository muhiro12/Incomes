//
//  ItemFormInference.swift
//  Incomes
//
//  Moved from IncomesLibrary to app to avoid AppIntents in the library.
//

import AppIntents
import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
public nonisolated struct ItemFormInference: AppEntity {
    @Guide(description: "Date formatted as yyyyMMdd")
    public var date: String
    @Guide(description: "Item content")
    public var content: String
    @Guide(description: "Income amount")
    public var income: Decimal
    @Guide(description: "Outgo amount")
    public var outgo: Decimal
    @Guide(description: "Category name")
    public var category: String

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Item Form Inference")
    }

    public static let defaultQuery = ItemFormInferenceQuery()

    public var id: String { "\(date)-\(content)-\(category)" }

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(content)", subtitle: "\(date)")
    }
}

@available(iOS 26.0, *)
public struct ItemFormInferenceQuery: EntityStringQuery {
    public init() {}
    public func entities(for _: [String]) throws -> [ItemFormInference] { [] }
    public func entities(matching _: String) throws -> [ItemFormInference] { [] }
    public func suggestedEntities() throws -> [ItemFormInference] { [] }
}
