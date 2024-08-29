//
//  YearView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/30/24.
//

import SwiftUI

struct YearView: View {
    @Environment(Tag.self)
    private var tag

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    var body: some View {
        List {
            ChartSections(items: tag.items.orEmpty)
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
        }
        .navigationTitle(tag.displayName)
    }
}

#Preview {
    IncomesPreview { preview in
        YearView()
            .environment(preview.tags[0])
    }
}
