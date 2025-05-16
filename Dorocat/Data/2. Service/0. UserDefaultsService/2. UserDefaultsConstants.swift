//
//  UserDefaultsConstants.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation

struct UserDefaultsConstants {
    enum Keys {
        case hapticEnabled
        case sessionSelect
        case catTypeSelect
        case promodeEnabled
        case progressEntity
        case settingEntity
        case cloudSync(CloudSyncKeys)
        
        var rawValue: String {
            switch self {
            case .cloudSync(let key): key.rawValue
            case .hapticEnabled: "HapticEnabled"
            case .sessionSelect: "SelectedSession"
            case .catTypeSelect: "SelectedCatType"
            case .promodeEnabled: "IsPromode"
            case .progressEntity: "TimerProgressEntity"
            case .settingEntity: "TimerSettingEntity"
            }
        }
    }
    enum CloudSyncKeys: String {
        case lastSyncedDate = "lastSyncedDate"
        case cloudSyncEnabled = "isIcloudSyncEnabled"
        case automaticallySyncEnabled = "isAutomaticallySyncEnabled"
    }
}

