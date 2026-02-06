import Foundation
import SwiftData

public struct MainNavigationState {
    public let isIntroductionPresented: Bool
    public let yearTag: Tag?
    public let yearMonthTag: Tag?

    public init(
        isIntroductionPresented: Bool,
        yearTag: Tag?,
        yearMonthTag: Tag?
    ) {
        self.isIntroductionPresented = isIntroductionPresented
        self.yearTag = yearTag
        self.yearMonthTag = yearMonthTag
    }
}

public enum MainNavigationStateLoader {
    public static func load(
        context: ModelContext,
        date: Date = .now
    ) throws -> MainNavigationState {
        let isIntroductionPresented = try ItemService.allItemsCount(
            context: context
        ).isZero
        let yearTag = try TagService.getByName(
            context: context,
            name: date.stableStringValueWithoutLocale(.yyyy),
            type: .year
        )
        let yearMonthTag = try TagService.getByName(
            context: context,
            name: date.stableStringValueWithoutLocale(.yyyyMM),
            type: .yearMonth
        )
        return .init(
            isIntroductionPresented: isIntroductionPresented,
            yearTag: yearTag,
            yearMonthTag: yearMonthTag
        )
    }
}
