//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ContentView {
    @Environment(\.modelContext)
    private var context
    @Environment(\.scenePhase)
    private var scenePhase

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn
    @AppStorage(.key(.isMaskAppOn))
    private var isMaskAppOn = UserDefaults.isMaskAppOn
    @AppStorage(.key(.isLockAppOn))
    private var isLockAppOn = UserDefaults.isLockAppOn

    @State private var contentID: Tag.ID?
    @State private var detailID: Item.ID?
    @State private var isHome = true
    @State private var isMasked = false
    @State private var isLocked = UserDefaults.isLockAppOn
}

extension ContentView: View {
    var body: some View {
        ZStack {
            NavigationSplitView {
                if isHome {
                    HomeView(contentID: $contentID)
                } else {
                    CategoryView(contentID: $contentID)
                }
                IncomesBottomBar(isHome: $isHome)
            } content: {
                if let contentID,
                   let tag = try? TagService(context: context).tag(predicate: Tag.predicate(id: contentID)) {
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
                        }(),
                        detailID: $detailID)
                }
            } detail: {
                if let detailID,
                   let item = try? ItemService(context: context).item(predicate: Item.predicate(id: detailID)) {
                    ItemDetailView(of: item)
                }
            }
            .onChange(of: scenePhase) { _, newValue in
                isMasked = isMaskAppOn && newValue != .active
                if !isLocked {
                    isLocked = isLockAppOn && newValue == .background
                }
            }
            if isMasked {
                MaskView()
            } else if isLocked {
                LockedView(isLocked: $isLocked)
            }
        }
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        ContentView()
    }
}
