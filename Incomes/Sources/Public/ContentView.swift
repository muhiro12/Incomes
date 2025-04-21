//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

public struct ContentView {
    public init() {}
}

extension ContentView: View {
    public var body: some View {
        MainView()
    }
}

#Preview {
    IncomesPreview { _ in
        ContentView()
    }
}
