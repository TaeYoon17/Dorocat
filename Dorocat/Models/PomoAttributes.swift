//
//  ActivityValue.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
import ActivityKit
struct PomoAttributes:ActivityAttributes{
    struct ContentState:Codable,Hashable{
        var timerStatus: ActivityTimerStatus = .focus
        var count:Int = 0
        var endTime:Int = 0
//        var cycle:Int = 0
//        var isPomoMode:Bool = false
//        var focusTime:Int = 0
//        var breakTime:Int = 0
    }
}
enum Status: String,CaseIterable,Codable,Equatable{
    case received = "eraser"
    case progress = "plus.fill"
    case ready = "pencil.circle.fill"
}
