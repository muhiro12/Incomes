//
//  ItemExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

// MARK: - Predicate

extension Item {
    typealias Predicate = Foundation.Predicate<Item>

    static func predicate(id: Item.ID) -> Predicate {
        #Predicate {
            $0.persistentModelID == id
        }
    }

    static func predicate(dateIsBetween start: Date, and end: Date) -> Predicate {
        #Predicate {
            start <= $0.date && $0.date <= end
        }
    }

    static func predicate(dateIsSameMonthAs date: Date) -> Predicate {
        predicate(dateIsBetween: Calendar.utc.startOfMonth(for: date),
                  and: Calendar.utc.endOfMonth(for: date))
    }

    static func predicate(dateIsSameYearAs date: Date) -> Predicate {
        predicate(dateIsBetween: Calendar.utc.startOfYear(for: date),
                  and: Calendar.utc.endOfYear(for: date))
    }

    static func predicate(dateIsAfter date: Date) -> Predicate {
        #Predicate {
            $0.date >= date
        }
    }

    static func predicate(contentIs content: String) -> Predicate {
        #Predicate {
            $0.content == content
        }
    }

    static func predicate(groupIs group: String) -> Predicate {
        #Predicate {
            $0.group == group
        }
    }

    static func predicate(groupIsNot group: String) -> Predicate {
        #Predicate {
            $0.group != group
        }
    }

    static func predicate(repeatIDIs repeatID: UUID) -> Predicate {
        #Predicate {
            $0.repeatID == repeatID
        }
    }

    static func predicate(repeatIDIs repeatID: UUID, dateIsAfter date: Date) -> Predicate {
        #Predicate {
            $0.repeatID == repeatID && $0.date >= date
        }
    }
}

// MARK: - SortDescriptor

extension Item {
    typealias SortDescriptor = Foundation.SortDescriptor<Item>

    static func sortDescriptors() -> [SortDescriptor] {
        [.init(\.date, order: .reverse),
         .init(\.content, order: .reverse),
         .init(\.persistentModelID, order: .reverse)]
    }
}
