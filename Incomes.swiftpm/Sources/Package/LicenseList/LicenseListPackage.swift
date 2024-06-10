//
//  LicenseListPackage.swift
//
//
//  Created by Hiromu Nakano on 2024/06/05.
//

import SwiftUI

@Observable
final class LicenseListPackage {
    private let builder: () -> AnyView

    init(builder: @escaping () -> some View) {
        self.builder = {
            .init(builder())
        }
    }

    func callAsFunction() -> some View {
        builder()
    }
}
