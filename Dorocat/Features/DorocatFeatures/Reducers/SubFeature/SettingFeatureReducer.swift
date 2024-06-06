//
//  SettingFeatureReducer.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture
extension DorocatFeature{
    func settingFeatureReducer(state: inout State,subAction action: SettingFeature.Action)-> Effect<Action>{
        switch action {
        default: return .none
        }
        return .none
    }
}
