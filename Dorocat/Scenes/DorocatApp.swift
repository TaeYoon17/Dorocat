//
//  DorocatApp.swift
//  Dorocat
//
//  Created by Developer on 3/11/24.
//

import SwiftUI
import ComposableArchitecture
import ActivityKit
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


@main
struct DorocatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
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
                .onReceive(ActivityIntentManager.eventPublisher.receive(on: RunLoop.main), perform: { (prevValue,nextValue) in
                    print("TimerStatus: \(prevValue) \(nextValue)")
                    store.send(.setActivityAction(prev: prevValue, next: nextValue))
                })
        }
        .onChange(of: phase) { oldValue, newValue in
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
