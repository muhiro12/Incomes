import Foundation

public enum TagItemFiltering {
    public static func items(
        for tag: Tag,
        yearString: String
    ) -> [Item] {
        tag.items.orEmpty
            .filter { item in
                item.year?.name == yearString
            }
            .sorted()
    }

    public static func yearStrings(
        for tag: Tag
    ) -> [String] {
        Set(
            tag.items.orEmpty.map { item in
                item.localDate.stringValueWithoutLocale(.yyyy)
            }
        )
        .sorted(by: >)
    }
}
