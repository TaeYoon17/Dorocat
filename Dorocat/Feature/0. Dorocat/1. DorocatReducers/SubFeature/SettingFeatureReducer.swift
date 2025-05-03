//
//  SettingFeatureReducer.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture
extension DorocatFeature{
    func settingFeatureReducer(state: inout State,subAction action: SettingFeature.Action)-> Effect<Action> {
        switch action {
        case .openIcloudSettingsDestination:
            state.path.append(.registerICloudSettingScene(.init()))
            return .none
        default: return .none
        }
        return .none
    }
}
