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
            Group {
                #if XCODE
                if #available(iOS 18.0, *) {
                    TabView(selection: $yearTag) {
                        ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                            Tab(value: yearTag) {
                                HomeTabSectionLink()
                                    .environment(yearTag)
                            }
                        }
                    }
                } else {
                    TabView(selection: $yearTag) {
                        ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                            HomeTabSectionLink()
                                .environment(yearTag)
                                .tag(yearTag as Tag?)
                        }
                    }
                }
                #else
                TabView(selection: $yearTag) {
                    ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                        HomeTabSectionLink()
                            .environment(yearTag)
                            .tag(yearTag as Tag?)
                    }
                }
                #endif
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .buttonStyle(.plain)
            .frame(height: .componentM)
        } footer: {
            HStack {
                ForEach(yearTags) { yearTag in
                    Circle()
                        .frame(width: 8)
                        .foregroundStyle(self.yearTag == yearTag ? AnyShapeStyle(.tint) : AnyShapeStyle(.tint.secondary))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            List {
                HomeTabSection()
            }
        }
    }
}
