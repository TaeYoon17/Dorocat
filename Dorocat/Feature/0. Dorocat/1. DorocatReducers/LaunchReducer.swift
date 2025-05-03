//
//  LaunchReducer.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ComposableArchitecture
extension DorocatFeature{
    func launchReducer(state:inout State) -> Effect<Action> {
        if !state.isAppLaunched {
            state.isAppLaunched = true
            state.guideState.onBoardingFinished = true
            return Effect.merge(
                .run { send in
                    let guides = await self.guideDefaults.get()
                    await send(.setGuideStates(guides))
                    await send(.timer(.setGuideState(guides)))
                    let isPro = store.isProUser
                    await send(.setProUser(isPro))
                    for await storeEvent in await store.eventAsyncStream(){
                        switch storeEvent{
                        case .userProUpdated(let isPro):
                            await send(.setProUser(isPro))
                        }
                    }
                },
                .run(operation: { send in
                    if await !initial.isUsed{
                        await initial.offInitial()
                        await send(.initialAction)
                    }
                }),
                .run{ send in
                    try! await session.initAction()
                },
                .run(operation: { send in
                    let prevVersion:String = UserDefaults.standard.string(forKey: "ShortAppVersion") ?? "1.0.0"
                    var actions: [Action] = []
                    
                    /// 앱에 남아있던 이전 버전에 대한 대응
                    
                    /// 앱 버전이 1.0.0이라고 해보자 - 다음 버전은 1.2.0으로 둘 것이다.
                    /// 이전 버전이 1.2.0 보다 적었다.
                    if isVersionLower(currentVersion: prevVersion, comparedTo: "1.2.0") {
                        let guides = await self.guideDefaults.get()
                        /// 온보딩을 진행했다면 동기화 할지 물어본다.
                        if guides.onBoardingFinished {
                            actions.append(.openRequestIcloudSyncSheet)
                        }
                    }
                    
                    /// 현재 업데이트 이후 현재 버전에 대한 대응
                    
                    /// 현재 버전으로 업데이트
                    let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0.0"
                    UserDefaults.standard.set(appVersion, forKey: "ShortAppVersion")
                    for action in actions {
                        await send(action)
                    }
                })
            )
        } else {
            return .none
        }
    }
}

/// 현재 앱 버전이 최신 버전보다 낮은지 확인하는 함수
/// 예: "1.3.2" < "1.5.0" → true
func isVersionLower(currentVersion: String, comparedTo latestVersion: String) -> Bool {
    // .numeric 옵션: "1.10" > "1.2"로 올바르게 비교됨
    return currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending
}
