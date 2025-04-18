//
//  DorocatApp.swift
//  Dorocat
//
//  Created by Developer on 3/11/24.
//

import SwiftUI
import DoroDesignSystem
import UIKit
import CloudKit

import ComposableArchitecture
import ActivityKit

import Firebase
import FirebaseCrashlytics



class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    lazy var allowCloudKitSync: Bool = {
        let arguments = ProcessInfo.processInfo.arguments
        var allow = true
        for index in 0..<arguments.count - 1 where arguments[index] == "-CDCKDAllowCloudKitSync" {
            allow = arguments.count >= (index + 1) ? arguments[index + 1] == "1" : true
            break
        }
        return allow
    }()
}


@main
struct DorocatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var phase
    let store = Store(initialState: DorocatFeature.State(), reducer: { DorocatFeature()})
    var body: some Scene {
        WindowGroup {
            let scope = Bindable(store).scope<DorocatFeature.State, DorocatFeature.DoroPath.State, DorocatFeature.DoroPath.Action>(state: \.path, action: \.actionPath)
            NavigationStack(path: scope) {
                ZStack {
                    DefaultBG().ignoresSafeArea(.all)
                    DoroMainView(store: store)
                }
                .preferredColorScheme(.dark)
                .toolbar(.hidden, for: .navigationBar)
            } destination: { store in
                switch store.state {
                case .registerICloudSettingScene:
                    if let store = store.scope(state: \.registerICloudSettingScene, action: \.iCloudSetting) {
                        IcloudSyncView(store: store)
                    }
                }
            }
            .onAppear(){ store.send(.launchAction) }
            .onReceive(ActivityIntentManager.eventPublisher.receive(on: RunLoop.main), perform: { (prevValue,nextValue) in
                print("TimerStatus: \(prevValue) \(nextValue)")
                store.send(.setActivityAction(prev: prevValue, next: nextValue))
            })
            .onAppear(){
                UIView.appearance().tintColor = .doroWhite
            }.loadDoroFontSystem()
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
