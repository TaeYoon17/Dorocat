//
//  DorocatApp.swift
//  Dorocat
//
//  Created by Developer on 3/11/24.
//

import SwiftUI
import ComposableArchitecture
@main
struct DorocatApp: App {
    @Environment(\.scenePhase) var phase
    let store = Store(initialState: DorocatFeature.State(),
                      reducer: { DorocatFeature()})
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {   
                DoroMainView(store: store)
            }
        }.onChange(of: phase) { newValue in
            switch newValue{
            case .active: store.send(.setAppState(.active))
            case .inactive: store.send(.setAppState(.inActive))
            case .background: store.send(.setAppState(.background))
            @unknown default: fatalError("이게 생기나?")
            }
        }
    }
}
