//
//  TimerStatus.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation

enum SleepStatus: Equatable{
    case focusSleep
    case breakSleep
}

enum TimerStatus:Equatable,Codable{
    case standBy
    case focus
    case pause
//    case sleep(SleepStatus)
    case focusSleep
    case breakSleep
    case breakStandBy
    case focusStandBy
    case breakTime
    case completed
}
extension TimerActivityType{
    var convertToTimerStatus: TimerStatus{
        return switch self{
        case .breakSleep: .breakSleep
        case .focusSleep: .focusSleep
        case .pause: .pause
        case .standBy: .standBy
        }
    }
}
extension TimerStatus{
    var convertToTimerActivityType:TimerActivityType?{
        switch self{
        case .focusSleep: .focusSleep
        case .breakSleep: .breakSleep
//        case .sleep(.focusSleep): TimerActivityType.focusSleep
//        case .sleep(.breakSleep): TimerActivityType.breakSleep
        case .pause: TimerActivityType.pause
        case .standBy: TimerActivityType.standBy
        default: nil
        }
    }
}
