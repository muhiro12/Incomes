//
//  ColorExtension.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/11/24.
//

import SwiftUI

extension Color {
    func adjusted(with adjustmentValue: Int) -> Color {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return self
        }

        let red = components[0]
        let green = components[1]
        let blue = components[2]

        let redAdjustment = CGFloat(adjustmentValue % 61 - 30)
        let greenAdjustment = CGFloat((adjustmentValue / 61) % 61 - 30)
        let blueAdjustment = CGFloat((adjustmentValue / (61 * 61)) % 61 - 30)

        let newRed = min(max(red + redAdjustment / 255, 0), 1)
        let newGreen = min(max(green + greenAdjustment / 255, 0), 1)
        let newBlue = min(max(blue + blueAdjustment / 255, 0), 1)

        return Color(red: newRed, green: newGreen, blue: newBlue)
    }
}
