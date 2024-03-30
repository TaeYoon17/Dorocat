//
//  TimerFeature+TimerInformation.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
struct TimerInformation:Codable,Equatable{
    var timeSeconds: Int = 0
    var cycle: Int = 0
    var shortBreak: Int = 0
    var longBreak: Int = 0
    var isPomoMode = false
}
extension TimerInformation{
    static func defaultCreate()->Self{
        TimerInformation(timeSeconds: 25 * 60, cycle: 0, shortBreak: 0, longBreak: 0, isPomoMode: false)
    }
}
