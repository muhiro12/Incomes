//
//  ItemFormInference.swift
//  Incomes
import AppIntents
import Foundation

@available(iOS 26.0, *)
public struct ItemFormInference: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Item Form Inference")
    }

    public static let defaultQuery = ItemFormInferenceQuery()

    public var date: String
    public var content: String
    public var income: Decimal
    public var outgo: Decimal
    public var category: String

    public var id: String { "\(date)-\(content)-\(category)" }

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(content)", subtitle: "\(date)")
    }

    init(result: ItemFormInferenceResult) {
        date = result.date
        content = result.content
        income = result.income
        outgo = result.outgo
        category = result.category
    }
}
