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

    @BridgeQuery(.tags(.typeIs(.year)))
    private var yearTagEntities: [TagEntity]

    @Binding private var yearTagEntity: TagEntity?

    init(selection: Binding<TagEntity?> = .constant(nil)) {
        _yearTagEntity = selection
    }

    private var availableYearTagEntities: [TagEntity] {
        yearTagEntities.filter { entity in
            guard let model = try? entity.model(in: context) else {
                return false
            }
            return model.items.isNotEmpty
        }
    }

    var body: some View {
        Section {
            Group {
                if #available(iOS 18.0, *) {
                    TabView(selection: $yearTagEntity) {
                        ForEach(availableYearTagEntities) { entity in
                            Tab(value: entity) {
                                HomeTabSectionLink()
                                    .environment(entity)
                            }
                        }
                    }
                } else {
                    TabView(selection: $yearTagEntity) {
                        ForEach(availableYearTagEntities) { entity in
                            HomeTabSectionLink()
                                .environment(entity)
                                .tag(entity as TagEntity?)
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
