//
//  DateExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

nonisolated extension Date {
    func stringValue(_ template: DateFormatter.Template, locale: Locale = .current) -> String {
        DateFormatter.default(template, locale: locale).string(from: self)
    }

    func stringValueWithoutLocale(_ template: DateFormatter.Template) -> String {
        DateFormatter.fixed(template).string(from: self)
    }
}
