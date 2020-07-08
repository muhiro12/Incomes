//
//  DateExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Date {
    enum Template: String {
        case yyyy
        case yyyyMMM
        case MMMd
        case yyyyMMMd
    }

    private static let formatter = DateFormatter()

    func stringValue(_ template: Template = .yyyyMMMd) -> String {
        Date.formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue,
                                                             options: 0,
                                                             locale: .current)
        return Date.formatter.string(from: self)
    }
}
