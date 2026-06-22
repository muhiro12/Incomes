//
//  StatusToolbarItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/09/15.
//

import SwiftUI

struct StatusToolbarItem<Content: View>: ToolbarContent {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

extension StatusToolbarItem {
    @ToolbarContentBuilder var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .largeSubtitle) {
                content
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            ToolbarItem(placement: .status) {
                content
                    .font(.footnote)
            }
        }
    }
}

extension StatusToolbarItem where Content == Text {
    init(_ content: LocalizedStringResource) {
        self.init {
            Text(content)
        }
    }
}

#Preview {
    NavigationStack {
        Text("Text")
            .navigationTitle("Title")
            .toolbar {
                StatusToolbarItem("Status")
            }
    }
}
