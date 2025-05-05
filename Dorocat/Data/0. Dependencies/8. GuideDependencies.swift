//
//  GuideDependencies.swift
//  Dorocat
//
//  Created by Developer on 4/2/24.
//

import Foundation
import ComposableArchitecture

protocol GuideProtocol{
    var goLeft:Bool { get async } // 타이머에서 왼쪽으로 가는 경우에 가이드
    var goRight:Bool { get async } // 타이머에서 오른쪽으로 가는 경우에 가이드
    var onBoarding:Bool { get async } // 온보딩에 나타나는 가이드
    var standByGuide:Bool { get async } // StandBy일 때, 타이머 버튼을 누르라고 알리는 가이드
    var startGuide:Bool { get async } // 처음 타이머 시작시 알리는 가이드
    func set(guide:Guides)async
    func get() async -> Guides
}
fileprivate enum GuideDefaultsClientKey: DependencyKey{
    static let liveValue: GuideProtocol = GuideClient()
}
extension DependencyValues{
    var guideDefaults: GuideProtocol{
        get{self[GuideDefaultsClientKey.self]}
        set{self[GuideDefaultsClientKey.self] = newValue}
    }
}
