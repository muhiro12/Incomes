//
//  HomeYearPagerSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeYearPagerSection: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]

    @Binding private var yearTag: Tag?

    init(selection: Binding<Tag?> = .constant(nil)) {
        _yearTag = selection
    }

    private var availableYearTags: [Tag] {
        yearTags.filter(\.items.isNotEmpty)
    }

    var body: some View {
        Section {
            Group {
                if #available(iOS 18.0, *) {
                    TabView(selection: $yearTag) {
                        ForEach(availableYearTags) { tag in
                            Tab(value: tag) {
                                HomeYearPagerLink()
                                    .environment(tag)
                            }
                        }
                    }
                } else {
                    TabView(selection: $yearTag) {
                        ForEach(availableYearTags) { tag in
                            HomeYearPagerLink()
                                .environment(tag)
                                .tag(tag as Tag?)
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .buttonStyle(.plain)
            .frame(height: .componentM)
        } footer: {
            HStack {
                ForEach(availableYearTags) { tag in
                    Circle()
                        .frame(width: 8)
                        .foregroundStyle(yearTag == tag ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
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
                HomeYearPagerSection()
            }
        }
    }
}
