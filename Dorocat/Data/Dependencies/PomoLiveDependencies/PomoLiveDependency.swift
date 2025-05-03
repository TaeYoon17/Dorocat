//
//  PomoLiveDependency.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
import ComposableArchitecture
import ActivityKit

protocol PomoLiveActivity {
    // 기존에 없으면 라이브 액티비티를 추가하고 존재하면 라이브 액티비티 값을 바꾸는 메서드
    func createActivity(type: TimerActivityType,item:SessionItem,cat:CatType,restCount: Int,totalCount:Int) async
    // 기존에 존재하는 라이브 액티비티의 값을 바꾸는 메서드
    func updateActivity(type: TimerActivityType,item:SessionItem,cat:CatType,restCount: Int) async
    // 라이브 액티비티를 추가하는 메서드
    func addActivity(type:TimerActivityType,item:SessionItem,cat:CatType,restCount: Int,totalCount:Int) async
    // 라이브 액티비티를 삭제하는 메서드
    func removeActivity() async
    func removeActivity(dismissPolicy: ActivityUIDismissalPolicy) async
}

fileprivate enum PomoLiveActivityClientKey: DependencyKey{
    static let liveValue: PomoLiveActivity = PomoLiveActivityClient.shared
}
extension DependencyValues{
    var pomoLiveActivity: PomoLiveActivity{
        get{self[PomoLiveActivityClientKey.self]}
        set{self[PomoLiveActivityClientKey.self] = newValue}
    }
}
