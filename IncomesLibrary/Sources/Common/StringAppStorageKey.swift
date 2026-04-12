//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import MHPlatformCore

public enum StringAppStorageKey: CaseIterable, MHStringPrefDescriptorRepresentable {
    case currencyCode
    case lastLaunchedAppVersion

    public var storageKey: String {
        switch self {
        case .currencyCode:
            IncomesAppStorageKeys.Standard.currencyCode.rawValue
        case .lastLaunchedAppVersion:
            IncomesAppStorageKeys.Standard.lastLaunchedAppVersion.rawValue
        }
    }

    public var preferenceDescriptor: MHStringPreferenceDescriptor {
        .init(
            storageKey: storageKey,
            defaultSelection: .standard
        )
    }
}
