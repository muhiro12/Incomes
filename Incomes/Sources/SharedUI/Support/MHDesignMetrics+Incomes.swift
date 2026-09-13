import MHDesign

extension MHDesignMetrics {
    // swiftlint:disable no_magic_numbers
    /// The app's established layout values, independent of package defaults.
    static let incomes: Self = .init(
        spacing: .init(
            inline: 8,
            control: 16,
            content: 24,
            section: 32,
            screen: 40
        ),
        cornerRadius: .init(
            control: 8,
            surface: 16
        ),
        layout: .init(
            readableContentWidth: 640,
            compactWidthThreshold: 600,
            screen: .init(
                contentInsetHorizontal: 40,
                contentInsetVertical: 72,
                contentSpacing: 48,
                compactContentInsetHorizontal: 16,
                compactContentInsetVertical: 32,
                compactContentSpacing: 24
            ),
            surface: .init(
                insetHorizontal: 24,
                insetVertical: 24,
                compactInsetHorizontal: 16,
                compactInsetVertical: 16
            ),
            control: .init(
                minimumTouchTarget: 44
            )
        )
    )
    // swiftlint:enable no_magic_numbers
}
