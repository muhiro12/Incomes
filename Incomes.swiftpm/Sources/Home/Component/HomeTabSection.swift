//
//  HomeTabSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeTabSection {
    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]

    @Binding private var yearTag: Tag?

    init(selection: Binding<Tag?> = .constant(nil)) {
        _yearTag = selection
    }
}

extension HomeTabSection: View {
    var body: some View {
        Section {
            #if XCODE
            if #available(iOS 18.0, *) {
                TabView(selection: $yearTag) {
                    ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                        Tab(value: yearTag) {
                            NavigationLink(value: IncomesPath.year(yearTag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast)) {
                                Text(yearTag.displayName)
                            }
                        }
                    }
                }
            } else {
                TabView(selection: $yearTag) {
                    ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                        NavigationLink(value: IncomesPath.year(yearTag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast)) {
                            Text(yearTag.displayName)
                        }
                        .tag(yearTag as Tag?)
                    }
                }
            }
            #else
            TabView(selection: $yearTag) {
                ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                    NavigationLink(value: IncomesPath.year(yearTag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast)) {
                        Text(yearTag.displayName)
                    }
                    .tag(yearTag as Tag?)
                }
            }
            #endif
        }
        .tabViewStyle(.page)
        .listRowInsets(.init())
        .frame(height: .componentM)
        .background(.tint.quinary)
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            HomeTabSection()
        }
    }
}
