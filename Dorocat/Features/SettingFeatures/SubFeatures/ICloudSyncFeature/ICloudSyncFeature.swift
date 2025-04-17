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
    struct State: Equatable{
        var isSyncEnabled: Bool = false
    }
    
    enum Action {
        case updateSyncStatus
        case setIsSyncEnabled(_ isEnabled: Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .updateSyncStatus: return .none
            case .setIsSyncEnabled(let isEnabled): return .none
            }
        }
    }
}
