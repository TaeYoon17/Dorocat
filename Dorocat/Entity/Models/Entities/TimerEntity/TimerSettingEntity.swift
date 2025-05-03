//
//  TimerSettingEntity.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation

struct TimerSettingEntity:Codable,Equatable{
    var timeSeconds: Int = 25 * 60
    var cycle: Int = 2
    var breakTime: Int = 1
    var isPomoMode = true
}
