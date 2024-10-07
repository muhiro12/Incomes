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
            HStack {
                Button {
                    guard let index = nextIndex(reverse: true) else {
                        return
                    }
                    self.yearTag = yearTags[index]
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .foregroundStyle(
                            Color(.secondaryLabel),
                            Color(.secondarySystemFill)
                        )
                        .font(.title2)
                }
                .disabled(nextIndex(reverse: true) == nil)
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
                Button {
                    guard let index = nextIndex(reverse: false) else {
                        return
                    }
                    self.yearTag = yearTags[index]
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundStyle(
                            Color(.secondaryLabel),
                            Color(.secondarySystemFill)
                        )
                        .font(.title2)
                }
                .disabled(nextIndex(reverse: false) == nil)
            }
        }
        .frame(height: .componentM)
        .buttonStyle(.plain)
    }
}

private extension HomeTabSection {
    func nextIndex(reverse: Bool) -> Int? {
        guard let yearTag,
              let current = yearTags.firstIndex(of: yearTag) else {
            return nil
        }
        let index = current + (reverse ? -1 : 1)
        return yearTags.indices.contains(index) ? index : nil
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
