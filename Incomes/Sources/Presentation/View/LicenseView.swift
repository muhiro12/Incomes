//
//  LicenseView.swift
//
//
//  Created by Hiromu Nakano on 2024/06/05.
//

import LicenseList
import SwiftUI

struct LicenseView: View {
    var body: some View {
        LicenseListView()
            .licenseListViewStyle(.withRepositoryAnchorLink)
    }
}

#Preview {
    LicenseView()
}
