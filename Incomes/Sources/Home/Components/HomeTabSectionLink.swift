//
//  HomeTabSectionLink.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/8/24.
//

import SwiftUI
import SwiftUtilities

struct HomeTabSectionLink {
    @Environment(TagEntity.self)
    private var yearTagEntity: TagEntity
    @Environment(\.modelContext)
    private var context
}

extension HomeTabSectionLink: View {
    var body: some View {
        let tagModel = try? yearTagEntity.model(in: context)
        let income = tagModel?
            .items.orEmpty.reduce(.zero) { $0 + $1.income } ?? .zero
        let outgo = tagModel?
            .items.orEmpty.reduce(.zero) { $0 + $1.outgo } ?? .zero
        NavigationLink(value: yearTagEntity) {
            VStack(alignment: .leading) {
                Text(yearTagEntity.displayName)
                    .font(.title.bold())
                HStack {
                    Text("Total Income")
                    Spacer()
                    Text(income.asCurrency)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up")
                        .foregroundStyle(.tint)
                }
                .padding(.leading, .spaceL)
                HStack {
                    Text("Total Outgo")
                    Spacer()
                    Text(outgo.asMinusCurrency)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.red)
                }
                .padding(.leading, .spaceL)
            }
            .contentShape(.rect)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            HomeTabSectionLink()
                .environment(
                    preview.tags
                        .first { $0.type == .year }
                )
        }
    }
}
