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
    @Dependency(\.pomoLiveActivity) var activity
    let store = Store(initialState: DorocatFeature.State(), reducer: { DorocatFeature()})
    var body: some Scene {
        WindowGroup {
            ZStack {
                DefaultBG()
                DoroMainView(store: store)
            }.preferredColorScheme(.dark)
                .onAppear(){
                    store.send(.launchAction)
//                    NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object:nil, queue: .main) { _ in
//                        print("이거 시작!")
//                        let semaphore = DispatchSemaphore(value: 0)
//                        Task{@MainActor in
//                            print("콜콜??")
//                            for activity in Activity<PomoAttributes>.activities
//                            {
//                                print("Ending Live Activity: \(activity.id)")
//                                await activity.end(nil, dismissalPolicy: .immediate)
//                            }
//                            print("이거 끝!!")
//                            try await Task.sleep(for: .seconds(1))
//                            semaphore.signal()
//                        }
//                        print("기달~")
//                        semaphore.wait()
//                        
//                    }
                }
//                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { output in
//                    Task{
//                        print("끝내기다~")
//                        await activity.removeActivity()
//                    }
//                }
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
