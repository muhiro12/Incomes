//
//  Haptic.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

enum Haptic {
    case success
    case warning
    case selectionChanged
}

extension Haptic {
    func impact() {
        switch self {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .selectionChanged:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}
