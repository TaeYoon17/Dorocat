//
//  AnalyzeFeatureReducer.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture

extension DorocatFeature{
    func analyzeFeatureReducer(state: inout State,subAction action: AnalyzeFeature.Action)->Effect<Action>{
        switch action {
        default: return .none
        }
        return .none
    }
}
