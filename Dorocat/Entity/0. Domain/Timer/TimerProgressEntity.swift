//
//  TimerProgressEntity.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation


/// 타이머를 시작하고 어떤 상태인지 알려주는 값
/// 1. 시작한 시간
/// 2. 현재 진행 중인 사이클
/// 3. 현재 주기에서 남은 시간
/// 4. 이 타이머의 현재 상태 - 뽀모도로 정책에 따라 타입이 변경됨
/// 5. 이 타이머를 유저가 지정한 세션
struct TimerProgressEntity:Equatable, Codable {
    var startDate: Date = .init()
    var cycle: Int = 0
    var count: Int = 25 * 60
    var status: TimerStatus = .standBy
    var session: SessionItem = .init(name: "Focus")
}

