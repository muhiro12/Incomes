import SwiftUI

extension View {
    @ViewBuilder
    func incomesProminentControlStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
        }
    }

    @ViewBuilder
    func incomesSecondaryControlStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
        } else {
            buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    func incomesDismissControlStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
        } else {
            buttonStyle(.borderless)
        }
    }

    @ViewBuilder
    func incomesGlassSurface(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            incomesGlassEffect(cornerRadius: cornerRadius)
        } else {
            background(
                .regularMaterial,
                in: RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
            )
        }
    }

    @available(iOS 26.0, *)
    func incomesGlassEffect(
        cornerRadius: CGFloat,
        tint: Color? = nil,
        isInteractive: Bool = false
    ) -> some View {
        glassEffect(
            .regular
                .tint(tint)
                .interactive(isInteractive),
            in: .rect(cornerRadius: cornerRadius)
        )
    }
}
