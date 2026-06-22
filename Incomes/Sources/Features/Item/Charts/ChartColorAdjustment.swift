import CoreGraphics
import SwiftUI
import UIKit

enum ChartColorAdjustment {
    static func adjustedColor(_ color: Color, by percentage: Double) -> Color {
        guard let components = srgbComponents(from: color) else {
            return color
        }

        let adjusted = adjustedSRGBComponents(
            red: components.red,
            green: components.green,
            blue: components.blue,
            percentage: percentage
        )

        return Color(
            red: adjusted.red,
            green: adjusted.green,
            blue: adjusted.blue,
            opacity: components.opacity
        )
    }
}

private extension ChartColorAdjustment {
    enum Constants {
        static let highBrightnessThreshold: CGFloat = 0.55
        static let highSaturationHueShift: CGFloat = 0.11
        static let lowSaturationHueShift: CGFloat = 0.26
        static let lowSaturationThreshold: CGFloat = 0.15
        static let maximumUnit: CGFloat = 1
        static let minimumAdjustedBrightness: CGFloat = 0.25
        static let minimumAdjustedSaturation: CGFloat = 0.45
        static let minimumUnit: CGFloat = 0
        static let greenSectorOffset: CGFloat = 2
        static let blueSectorOffset: CGFloat = 4
        static let requiredComponentCount = 3
        static let saturationBoost: CGFloat = 0.18
        static let fullPercentage: CGFloat = 100
        static let brightnessAdjustment: CGFloat = 0.18
    }

    enum HSVSector: CaseIterable {
        case red
        case yellow
        case green
        case cyan
        case blue
        case magenta

        init(rawSector: Int) {
            let count = Self.allCases.count
            let normalized = ((rawSector % count) + count) % count
            self = Self.allCases[normalized]
        }
    }

    struct SRGBComponents {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let opacity: CGFloat
    }

    struct HSVComponents {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
    }

    static func adjustedSRGBComponents(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat,
        percentage: Double
    ) -> SRGBComponents {
        let amount = normalizedPercentage(percentage)
        let original = SRGBComponents(
            red: red,
            green: green,
            blue: blue,
            opacity: Constants.maximumUnit
        )
        guard amount > Constants.minimumUnit else {
            return original
        }

        let fullyAdjusted = fullAdjustedSRGBComponents(
            red: red,
            green: green,
            blue: blue
        )

        guard amount < Constants.maximumUnit else {
            return fullyAdjusted
        }

        return .init(
            red: blend(from: red, target: fullyAdjusted.red, amount: amount),
            green: blend(from: green, target: fullyAdjusted.green, amount: amount),
            blue: blend(from: blue, target: fullyAdjusted.blue, amount: amount),
            opacity: Constants.maximumUnit
        )
    }

    static func fullAdjustedSRGBComponents(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat
    ) -> SRGBComponents {
        let hsv = rgbToHSV(red: red, green: green, blue: blue)

        let hueShift = hsv.saturation < Constants.lowSaturationThreshold
            ? Constants.lowSaturationHueShift
            : Constants.highSaturationHueShift
        let adjustedHue = wrappedUnit(hsv.hue + hueShift)
        let adjustedSaturation = clamp(
            max(hsv.saturation + Constants.saturationBoost, Constants.minimumAdjustedSaturation),
            lower: Constants.minimumUnit,
            upper: Constants.maximumUnit
        )
        let brightnessDelta = hsv.brightness >= Constants.highBrightnessThreshold
            ? -Constants.brightnessAdjustment
            : Constants.brightnessAdjustment
        let adjustedBrightness = clamp(
            hsv.brightness + brightnessDelta,
            lower: Constants.minimumAdjustedBrightness,
            upper: Constants.maximumUnit
        )

        return hsvToRGB(
            hue: adjustedHue,
            saturation: adjustedSaturation,
            brightness: adjustedBrightness
        )
    }

    static func normalizedPercentage(_ percentage: Double) -> CGFloat {
        clamp(
            CGFloat(percentage) / Constants.fullPercentage,
            lower: Constants.minimumUnit,
            upper: Constants.maximumUnit
        )
    }

    static func blend(from: CGFloat, target: CGFloat, amount: CGFloat) -> CGFloat {
        from + (target - from) * amount
    }

    static func srgbComponents(from color: Color) -> SRGBComponents? {
        if
            let cgColor = color.cgColor,
            let components = srgbComponents(from: cgColor) {
            return components
        }

        let uiColor = UIColor(color)
        var red: CGFloat = Constants.minimumUnit
        var green: CGFloat = Constants.minimumUnit
        var blue: CGFloat = Constants.minimumUnit
        var alpha: CGFloat = Constants.minimumUnit
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return .init(red: red, green: green, blue: blue, opacity: alpha)
    }

    static func srgbComponents(from cgColor: CGColor) -> SRGBComponents? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let srgbColor = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil)
            ?? cgColor

        guard
            let components = srgbColor.components,
            components.count >= Constants.requiredComponentCount
        else {
            return nil
        }

        let redIndex = components.startIndex
        let greenIndex = components.index(after: redIndex)
        let blueIndex = components.index(after: greenIndex)
        return .init(
            red: components[redIndex],
            green: components[greenIndex],
            blue: components[blueIndex],
            opacity: srgbColor.alpha
        )
    }

    static func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }

    static func wrappedUnit(_ value: CGFloat) -> CGFloat {
        let wrapped = value.truncatingRemainder(dividingBy: Constants.maximumUnit)
        return wrapped < Constants.minimumUnit ? wrapped + Constants.maximumUnit : wrapped
    }

    static func rgbToHSV(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat
    ) -> HSVComponents {
        let maximum = max(red, max(green, blue))
        let minimum = min(red, min(green, blue))
        let delta = maximum - minimum

        var hue: CGFloat = Constants.minimumUnit
        if delta > Constants.minimumUnit {
            if maximum == red {
                hue = ((green - blue) / delta)
                    .truncatingRemainder(dividingBy: CGFloat(HSVSector.allCases.count))
            } else if maximum == green {
                hue = ((blue - red) / delta) + Constants.greenSectorOffset
            } else {
                hue = ((red - green) / delta) + Constants.blueSectorOffset
            }

            hue /= CGFloat(HSVSector.allCases.count)
            if hue < Constants.minimumUnit {
                hue += Constants.maximumUnit
            }
        }

        let saturation = maximum == Constants.minimumUnit ? Constants.minimumUnit : delta / maximum
        return .init(hue: hue, saturation: saturation, brightness: maximum)
    }

    static func hsvToRGB(
        hue: CGFloat,
        saturation: CGFloat,
        brightness: CGFloat
    ) -> SRGBComponents {
        let wrappedHue = wrappedUnit(hue)
        let sectorCount = CGFloat(HSVSector.allCases.count)
        let scaledHue = wrappedHue * sectorCount
        let rawSector = Int(floor(scaledHue))
        let sector = HSVSector(rawSector: rawSector)
        let fraction = scaledHue - CGFloat(rawSector)

        let pValue = brightness * (Constants.maximumUnit - saturation)
        let qValue = brightness * (Constants.maximumUnit - saturation * fraction)
        let tValue = brightness * (Constants.maximumUnit - saturation * (Constants.maximumUnit - fraction))

        switch sector {
        case .red:
            return .init(red: brightness, green: tValue, blue: pValue, opacity: Constants.maximumUnit)
        case .yellow:
            return .init(red: qValue, green: brightness, blue: pValue, opacity: Constants.maximumUnit)
        case .green:
            return .init(red: pValue, green: brightness, blue: tValue, opacity: Constants.maximumUnit)
        case .cyan:
            return .init(red: pValue, green: qValue, blue: brightness, opacity: Constants.maximumUnit)
        case .blue:
            return .init(red: tValue, green: pValue, blue: brightness, opacity: Constants.maximumUnit)
        case .magenta:
            return .init(red: brightness, green: pValue, blue: qValue, opacity: Constants.maximumUnit)
        }
    }
}
