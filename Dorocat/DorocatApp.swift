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
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {   
                DoroMainView(store: Store(initialState: DorocatFeature.State(), reducer: {
                    DorocatFeature()
                }))
            }
        }
    }
}
