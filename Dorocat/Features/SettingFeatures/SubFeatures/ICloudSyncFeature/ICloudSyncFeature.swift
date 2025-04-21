//
//  ICloudSyncFeature.swift
//  Dorocat
//
//  Created by Greem on 4/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ICloudSyncFeature {
    
    @ObservableState
    struct State: Equatable {
        
        var isSyncEnabled: Bool = true
        var isAutomaticSyncEnabled: Bool = false
        var isLoading: Bool = false
    }
    enum Action {
        case setIsSyncEnabled(_ isEnabled: Bool)
        case setIsAutomaticSyncEnabled(_ isEnabled: Bool)
        case refreshTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setIsSyncEnabled(let isEnabled):
                state.isSyncEnabled = isEnabled
                return .none
            case .setIsAutomaticSyncEnabled(let isEnabled):
                state.isAutomaticSyncEnabled = isEnabled
                return .none
            case .refreshTapped:
                state.isLoading.toggle()
                return .none
            }
        }
    }
}
