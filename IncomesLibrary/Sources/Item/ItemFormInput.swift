import Foundation

/// Normalized date and text inputs for creating or updating an item.
public struct ItemFormInput: Equatable {
    /// Validation errors for item form values.
    public enum ValidationError: Error, Equatable {
        /// Content is required.
        case contentIsEmpty
        /// Income text is not a valid decimal.
        case invalidIncome
        /// Outgo text is not a valid decimal.
        case invalidOutgo
        /// Income is a number the store cannot keep without changing its value.
        case unsupportedIncome
        /// Outgo is a number the store cannot keep without changing its value.
        case unsupportedOutgo
        /// Priority text is not a valid integer.
        case invalidPriority
    }

    /// Standard editor priorities; this does not restrict older stored integer values.
    public static let priorityRange = 0...10

    /// Ledger captured with the draft; changing the current selection cannot redirect it.
    public let ledgerIdentifier: LedgerIdentifier
    /// Selected local date for the item.
    public let date: Date
    /// Item description text.
    public let content: String
    /// Income amount entered as text.
    public let incomeText: String
    /// Outgo amount entered as text.
    public let outgoText: String
    /// Category name entered for the item.
    public let category: String
    /// Priority value entered as text.
    public let priorityText: String
    private let amountLocale: Locale?

    /// True when all form values pass `validate()`.
    public var isValid: Bool {
        (try? validate()) != nil
    }

    /// Income value parsed from `incomeText`.
    public var income: Decimal {
        parsedAmount(incomeText) ?? .zero
    }

    /// Outgo value parsed from `outgoText`.
    public var outgo: Decimal {
        parsedAmount(outgoText) ?? .zero
    }

    /// Priority value parsed from `priorityText`.
    public var priority: Int {
        priorityText.intValue
    }

    /// Category value normalized for persistence.
    public var storedCategory: String {
        CategoryNameSupport.normalizedStoredName(
            forUserInput: category
        )
    }

    /// Creates an item form input snapshot.
    /// An explicit locale fixes the interpretation of localized amount strings.
    /// Omission uses the manual editor's current-locale and English fallback rules.
    public init(
        date: Date,
        content: String,
        incomeText: String,
        outgoText: String,
        category: String,
        priorityText: String,
        ledgerIdentifier: LedgerIdentifier = .default,
        locale: Locale? = nil
    ) {
        self.date = date
        self.content = content
        self.incomeText = incomeText
        self.outgoText = outgoText
        self.category = category
        self.priorityText = priorityText
        self.ledgerIdentifier = ledgerIdentifier
        amountLocale = locale
    }

    /// Creates an item form input snapshot from typed amount and priority values.
    public init(
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int = 0,
        locale: Locale = .current,
        ledgerIdentifier: LedgerIdentifier = .default
    ) {
        self.init(
            date: date,
            content: content,
            incomeText: income.groupedDecimalText(locale: locale),
            outgoText: outgo.groupedDecimalText(locale: locale),
            category: category,
            priorityText: "\(priority)",
            ledgerIdentifier: ledgerIdentifier,
            locale: locale
        )
    }

    /// Creates an item form input snapshot from a draft.
    public init(draft: ItemFormDraft) {
        self.init(
            date: draft.date,
            content: draft.content,
            incomeText: draft.incomeText,
            outgoText: draft.outgoText,
            category: draft.category,
            priorityText: draft.priorityText.isEmpty ? "0" : draft.priorityText,
            ledgerIdentifier: draft.ledgerIdentifier
        )
    }

    /// Creates an item form input snapshot from an existing item.
    public init(
        item: Item,
        locale: Locale = .current
    ) {
        let incomeText = item.income != .zero
            ? item.income.groupedDecimalText(locale: locale)
            : ""
        let outgoText = item.outgo != .zero
            ? item.outgo.groupedDecimalText(locale: locale)
            : ""

        self.init(
            date: item.localDate,
            content: item.content,
            incomeText: incomeText,
            outgoText: outgoText,
            category: CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            ),
            priorityText: "\(item.priority)",
            ledgerIdentifier: item.ledgerIdentifier,
            locale: locale
        )
    }

    /// Validates form values and throws a specific validation error.
    public func validate() throws {
        guard !content.isEmpty else {
            throw ValidationError.contentIsEmpty
        }
        switch amountRejection(incomeText) {
        case .none:
            break
        case .notANumber:
            throw ValidationError.invalidIncome
        case .unsupportedAmount:
            throw ValidationError.unsupportedIncome
        }
        switch amountRejection(outgoText) {
        case .none:
            break
        case .notANumber:
            throw ValidationError.invalidOutgo
        case .unsupportedAmount:
            throw ValidationError.unsupportedOutgo
        }
        guard priorityText.isEmptyOrInt else {
            throw ValidationError.invalidPriority
        }
    }

    /// Returns a copy with `tag` applied as initial context.
    public func applying(
        tag: Tag,
        currentDate: Date
    ) -> Self {
        switch tag.type {
        case .year,
             .yearMonth:
            return replacing(
                date: ItemFormInitialDateResolver.date(
                    for: tag,
                    currentDate: currentDate
                )
            )
        case .content:
            return replacing(content: tag.name)
        case .category:
            return replacing(
                category: CategoryNameSupport.displayName(
                    forStoredName: tag.name
                )
            )
        case .debug, .ledger, .defaultLedger, .none:
            return self
        }
    }

    /// Reformats valid amounts for another editor locale without reinterpreting separators.
    /// Invalid source text remains visible so the editor can surface its validation error.
    public func localizedAmounts(locale: Locale = .current) -> Self {
        .init(
            date: date,
            content: content,
            incomeText: localizedAmountText(incomeText, locale: locale),
            outgoText: localizedAmountText(outgoText, locale: locale),
            category: category,
            priorityText: priorityText,
            ledgerIdentifier: ledgerIdentifier,
            locale: locale
        )
    }
}

private extension ItemFormInput {
    func parsedAmount(_ text: String) -> Decimal? {
        if let amountLocale {
            return DecimalTextParser.parse(text, locale: amountLocale)
        }
        return DecimalTextParser.parse(text)
    }

    func amountRejection(_ text: String) -> DecimalTextRejection? {
        guard !text.isEmpty else {
            return nil
        }
        if let amountLocale {
            return DecimalTextParser.rejection(for: text, locale: amountLocale)
        }
        return text.decimalRejection
    }

    func localizedAmountText(_ text: String, locale: Locale) -> String {
        guard let amount = parsedAmount(text) else {
            return text
        }
        return amount.groupedDecimalText(locale: locale)
    }

    func replacing(date: Date) -> ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: incomeText,
            outgoText: outgoText,
            category: category,
            priorityText: priorityText,
            ledgerIdentifier: ledgerIdentifier,
            locale: amountLocale
        )
    }

    func replacing(content: String) -> ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: incomeText,
            outgoText: outgoText,
            category: category,
            priorityText: priorityText,
            ledgerIdentifier: ledgerIdentifier,
            locale: amountLocale
        )
    }

    func replacing(category: String) -> ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: incomeText,
            outgoText: outgoText,
            category: category,
            priorityText: priorityText,
            ledgerIdentifier: ledgerIdentifier,
            locale: amountLocale
        )
    }
}

public extension ItemFormInput {
    /// Captures ownership when an adapter resolves an explicit item identity.
    func assigning(to identifier: LedgerIdentifier) -> Self {
        .init(
            date: date,
            content: content,
            incomeText: incomeText,
            outgoText: outgoText,
            category: category,
            priorityText: priorityText,
            ledgerIdentifier: identifier,
            locale: amountLocale
        )
    }
}
