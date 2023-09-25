//
//  RootNavigationView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/23.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct RootNavigationView {
    @Environment(\.modelContext)
    private var context

    @State private var contentID: SidebarItem.ID?
    @State private var detailID: Tag.ID?
}

extension RootNavigationView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $contentID)
        } content: {
            Group {
                if let contentID,
                   let item = SidebarItem(rawValue: contentID) {
                    switch item {
                    case .home:
                        HomeView(selection: $detailID)

                    case .category:
                        CategoryView(selection: $detailID)
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    CreateButton()
                }
                ToolbarItem(placement: .status) {
                    Text(.localized(.footerTextPrefix) + Date().stringValue(.yyyyMMMd))
                        .font(.footnote)
                }
            }
        } detail: {
            Group {
                if let detailID,
                   let tag = try? TagService(context: context).tag(predicate: Tag.predicate(id: detailID)) {
                    ItemListView(
                        tag: tag,
                        predicate: {
                            if tag.type == .yearMonth,
                               let date = tag.items?.first?.date {
                                return Item.predicate(dateIsSameMonthAs: date)
                            }
                            if tag.type == .content {
                                return Item.predicate(contentIs: tag.name)
                            }
                            return .false
                        }()
                    )
                }
            }
            .toolbar {
                ToolbarItem {
                    CreateButton()
                }
                ToolbarItem(placement: .status) {
                    Text(.localized(.footerTextPrefix) + Date().stringValue(.yyyyMMMd))
                        .font(.footnote)
                }
            }
        }
        .onAppear {
            contentID = SidebarItem.home.id
            detailID = try? TagService(context: context)
                .tag(predicate: Tag.predicate(dateIsSameMonthAs: .now))?
                .id
        }
    }
}

#Preview {
    ModelPreview { (_: Item) in
        RootNavigationView()
    }
}
