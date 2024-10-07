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
                                    .offset(y: -.spaceL)
                                    .environment(yearTag)
                            }
                        }
                    }
                } else {
                    TabView(selection: $yearTag) {
                        ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                            HomeTabSectionLink()
                                .offset(y: -.spaceL)
                                .environment(yearTag)
                                .tag(yearTag as Tag?)
                        }
                    }
                }
                #else
                TabView(selection: $yearTag) {
                    ForEach(yearTags.filter { $0.items.isNotEmpty }) { yearTag in
                        HomeTabSectionLink()
                            .offset(y: -.spaceL)
                            .environment(yearTag)
                            .tag(yearTag as Tag?)
                    }
                }
                #endif
            }
            .tabViewStyle(.page)
            .frame(height: .componentL)
            .offset(y: .spaceM)
        }
        .buttonStyle(.plain)
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = .systemGreen
            UIPageControl.appearance().pageIndicatorTintColor = .systemGreen.withAlphaComponent(0.5)
        }
        .onDisappear {
            UIPageControl.appearance().currentPageIndicatorTintColor = nil
            UIPageControl.appearance().pageIndicatorTintColor = nil
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
