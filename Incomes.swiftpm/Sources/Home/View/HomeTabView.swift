//
//  HomeTabView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeTabView {
    @Query(.tags(.typeIs(.year)))
    private var tags: [Tag]

    @Binding private var path: IncomesPath?

    @State private var tag: Tag?

    init(selection: Binding<IncomesPath?> = .constant(nil)) {
        _path = selection
    }
}

extension HomeTabView: View {
    var body: some View {
        Group {
            #if XCODE
            if #available(iOS 18.0, *) {
                TabView(selection: $tag) {
                    ForEach(tags.filter { $0.items.isNotEmpty }) { tag in
                        Tab(value: tag) {
                            HomeListView(yearTag: tag, selection: $path)
                        }
                    }
                }
            } else {
                TabView(selection: $tag) {
                    ForEach(tags.filter { $0.items.isNotEmpty }) { tag in
                        HomeListView(yearTag: tag, selection: $path)
                            .tag(tag as? Tag)
                    }
                }
            }
            #else
            TabView(selection: $tag) {
                ForEach(tags.filter { $0.items.isNotEmpty }) { tag in
                    HomeListView(yearTag: tag, selection: $path)
                        .tag(tag as Tag?)
                }
            }
            #endif
        }
        .tabViewStyle(.page)
        .navigationTitle(tag?.displayName ?? .empty)
        .toolbar {
            ToolbarItem {
                CreateButton()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
        .task {
            tag = tags.last
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            HomeTabView()
        }
    }
}
