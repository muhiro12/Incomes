//
//  GoogleMobileAdsControllerKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import GoogleMobileAdsWrapper
import SwiftUI

struct GoogleMobileAdsControllerKey: EnvironmentKey {
    static var defaultValue = GoogleMobileAdsController?(nil)
}

extension EnvironmentValues {
    var googleMobileAdsController: GoogleMobileAdsController? {
        get { self[GoogleMobileAdsControllerKey.self] }
        set { self[GoogleMobileAdsControllerKey.self] = newValue }
    }
}
