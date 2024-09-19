//
//  OldMainTabView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct OldMainTabView: View {
    var body: some View {
        TabView {
            Text("MainTab")
                .tabItem {
                    Label {
                        Text("Title")
                    } icon: {
                        Image(systemName: "house")
                    }
                }
        }
    }
}

#Preview {
    OldMainTabView()
}
