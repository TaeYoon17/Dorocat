//
//  DorocatApp.swift
//  Dorocat
//
//  Created by Developer on 3/11/24.
//

import SwiftUI
import DoroDesignSystem
import UIKit
import ComposableArchitecture
import ActivityKit


@main
struct DorocatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var phase
    
    let store = Store(
        initialState: DorocatFeature.State(),
        reducer: { DorocatFeature() }
    )
    
    var body: some Scene {
        WindowGroup {
            
            let scope = Bindable(store).scope<
                DorocatFeature.State,
                DorocatFeature.DoroPath.State,
                DorocatFeature.DoroPath.Action
            >(
                state: \.path,
                action: \.actionPath
            )
            
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
                    if let store: StoreOf<ICloudSyncFeature> = store.scope(
                        state: \.registerICloudSettingScene,
                        action: \.iCloudSetting
                    ) {
                        IcloudSyncView(store: store)
                    }
                }
            }
            .onAppear() {
                store.send(.launchAction)
            }
            .onReceive(
                ActivityIntentManager.eventPublisher.receive(on: RunLoop.main),
                perform: { (prevValue,nextValue) in
                    store.send(.setActivityAction(prev: prevValue, next: nextValue))
                }
            )
            .onAppear() {
                UIView.appearance().tintColor = .doroWhite
            }
            .loadDoroFontSystem()
        }
        .onChange(of: phase) { oldValue, newValue in
            switch newValue{
            case .active: store.send(.setAppState(.active))
            case .inactive: store.send(.setAppState(.inActive))
            case .background: store.send(.setAppState(.background))
            @unknown default:
                assertionFailure("값 변환에서 알 수 없는 오류")
                break
            }
        }
    }
}
