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
                if let content {
                    switch content {
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
                    Text("Today: \(Date().stringValue(.yyyyMMMd))")
                        .font(.footnote)
                }
            }
        } detail: {
            Group {
                if let detail {
                    ItemListView(tag: detail) { yearTag in
                        if detail.type == .yearMonth,
                           let date = detail.items?.first?.date {
                            return Item.predicate(dateIsSameMonthAs: date)
                        }
                        if detail.type == .content {
                            return Item.predicate(content: detail.name,
                                                  year: yearTag.name)
                        }
                        return .false
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    CreateButton()
                }
                ToolbarItem(placement: .status) {
                    Text("\(detail?.items?.count ?? .zero) Items")
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

private extension RootNavigationView {
    var content: SidebarItem? {
        guard let contentID else {
            return nil
        }
        return SidebarItem(rawValue: contentID)
    }

    var detail: Tag? {
        guard let detailID else {
            return nil
        }
        return try? TagService(context: context).tag(predicate: Tag.predicate(id: detailID))
    }
}

#Preview {
    RootNavigationView()
        .previewQuery()
}
