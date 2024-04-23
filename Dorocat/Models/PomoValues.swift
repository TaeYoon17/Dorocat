//
//  PomoValues.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
struct PomoValues:Equatable{
    var status:TimerFeatureStatus
    var information:TimerInformation?
    var cycle:Int
    var count:Int
    var startDate:Date
    static func deafultCreate()->Self{
        PomoValues(status: .standBy, information: TimerInformation(timeSeconds: 25 * 60, cycle: 1, breakTime: 1, isPomoMode: false), cycle: 0, count: 25 * 60,startDate: Date())
    }
}
