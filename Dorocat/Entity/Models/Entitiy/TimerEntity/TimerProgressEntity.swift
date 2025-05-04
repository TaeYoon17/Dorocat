//
//  TimerProgressEntity.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation

struct TimerProgressEntity:Equatable,Codable {
    var startDate: Date = .init()
    var cycle: Int = 0
    var count: Int = 25 * 60
    var status: TimerStatus = .standBy
    var session: SessionItem = .init(name: "Focus")
}

