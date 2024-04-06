//
//  TimerFeature+TimerInformation.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
struct TimerInformation:Codable,Equatable{
    var timeSeconds: Int = 0
    var cycle: Int = 2
    var breakTime: Int = 1
    var isPomoMode = false
}
extension TimerInformation{
    static func defaultCreate()->Self{
        TimerInformation(timeSeconds: 25 * 60, cycle: 2, breakTime: 1, isPomoMode: false)
    }
}
