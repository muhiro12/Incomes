//
//  HomeTabSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeTabSection: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year)))
    private var yearTagEntities: [Tag]

    @Binding private var yearTagEntity: Tag?

    init(selection: Binding<Tag?> = .constant(nil)) {
        _yearTagEntity = selection
    }

    private var availableYearTagEntities: [Tag] {
        yearTagEntities.filter(\.items.isNotEmpty)
    }

    var body: some View {
        Section {
            Group {
                if #available(iOS 18.0, *) {
                    TabView(selection: $yearTagEntity) {
                        ForEach(availableYearTagEntities) { tag in
                            Tab(value: tag) {
                                HomeTabSectionLink()
                                    .environment(tag)
                            }
                        }
                    }
                } else {
                    TabView(selection: $yearTagEntity) {
                        ForEach(availableYearTagEntities) { tag in
                            HomeTabSectionLink()
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
                ForEach(availableYearTagEntities) { entity in
                    Circle()
                        .frame(width: 8)
                        .foregroundStyle(yearTagEntity == entity ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
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
