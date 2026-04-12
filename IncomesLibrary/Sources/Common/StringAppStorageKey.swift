//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import MHPlatformCore

public enum StringAppStorageKey: String, CaseIterable, MHStringPrefDescriptorRepresentable {
    case currencyCode = "R8k2Z3tL"
    case lastLaunchedAppVersion = "j4N7v2Qk"

    public var preferenceDescriptor: MHStringPreferenceDescriptor {
        .init(
            storageKey: rawValue,
            defaultSelection: .standard
        )
    }
}
