//
//  TimerStatus.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
enum SleepStatus: Equatable{
    case focusSleep
    case breakSleep
}
enum TimerFeatureStatus:Equatable{
    case standBy
    case focus
    case pause
    case sleep(SleepStatus)
    case breakStandBy
    case breakTime
    case completed
}
enum ActivityTimerStatus:Codable,Hashable{
    case focus
    case pause
    case breakTime
}
extension TimerActivityType{
    var convertToTimerStatus: TimerFeatureStatus{
        return switch self{
        case .breakSleep: TimerFeatureStatus.sleep(.breakSleep)
        case .focusSleep: .sleep(.focusSleep)
        case .pause: .pause
        case .standBy: .standBy
        }
    }
}
extension TimerFeatureStatus{
    var convertToTimerActivityType:TimerActivityType?{
        switch self{
        case .sleep(.focusSleep): TimerActivityType.focusSleep
        case .sleep(.breakSleep): TimerActivityType.breakSleep
        case .pause: TimerActivityType.pause
        case .standBy: TimerActivityType.standBy
        default: nil
        }
    }
}
