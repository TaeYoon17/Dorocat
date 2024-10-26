//
//  PomoValues.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
struct PomoValues: Equatable {
    var catType: CatType
    var isProMode:Bool = false
    var status:TimerStatus
    var information:TimerSettingEntity?
    var cycle:Int
    var count:Int
    var sessionItem: SessionItem = .init(name: "Focus")
    var startDate:Date
}

extension PomoValues {
    static func deafultCreate()->Self{
        PomoValues(catType: .doro, isProMode: false, status: .standBy,
                   information: TimerSettingEntity(timeSeconds: 25 * 60, cycle: 1, breakTime: 1, isPomoMode: false),
                   cycle: 0,
                   count: 25 * 60,
                   startDate: Date()
        )
    }
}
