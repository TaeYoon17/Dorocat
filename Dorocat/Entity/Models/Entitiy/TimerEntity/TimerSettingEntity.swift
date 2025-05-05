//
//  TimerSettingEntity.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation

/// 유저가 설정한 타이머 구성 정보
/// 1. timerSeconds - 유저가 지정한 시간을 초 단위로 갖는다.
/// 2. cycle - 유저가 지정한 얼마나 순회할지
/// 3. breakTime - 유저가 지정한 쉬는 시간, 초 단위를 갖는다.
/// 4. isPomoMode - 뽀모도로 모드인지 단순 타이머 모드인지 Boolean
struct TimerSettingEntity: Codable, Equatable {
    var timeSeconds: Int = 25 * 60
    var cycle: Int = 2
    var breakTime: Int = 1
    var isPomoMode = true
}
