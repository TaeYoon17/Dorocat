//
//  DorocatApp.swift
//  Dorocat
//
//  Created by Developer on 3/11/24.
//

import SwiftUI
import ComposableArchitecture
import ActivityKit
@main
struct DorocatApp: App {
    @Environment(\.scenePhase) var phase
    let store = Store(initialState: DorocatFeature.State(), reducer: { DorocatFeature()})
    var body: some Scene {
        WindowGroup {
            ZStack {
                DefaultBG()
                DoroMainView(store: store)
            }.preferredColorScheme(.dark)
            .onAppear(){
                store.send(.launchAction)
            }
        }.onChange(of: phase) { oldValue, newValue in
            switch newValue{
            case .active: store.send(.setAppState(.active))
            case .inactive: store.send(.setAppState(.inActive))
            case .background: store.send(.setAppState(.background))
            @unknown default: fatalError("이게 생기나?")
            }
        }
    }
}
struct DefaultBG: View{
    var body: some View{
        ZStack{
            Color.grey04
            Image(.defaultBg).resizable(resizingMode: .tile)
        }.ignoresSafeArea(.all,edges: .all)
    }
}
