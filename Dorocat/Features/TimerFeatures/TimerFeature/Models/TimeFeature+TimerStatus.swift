//
//  TimeFeature+TimerStatus.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
enum PauseStatus:Equatable{
    case focusPause
    case breakPause
}
enum TimerFeatureStatus:Equatable{
    case standBy
    case focus
    case pause(PauseStatus)
    case completed
    case breakTime
}
extension TimerFeatureStatus{
    static func create(name:String) -> Self{
        switch name{
        case "standBy": .standBy
        case "focus": .focus
        case "pauseFocus": .pause(.focusPause)
        case "pauseBreak": .pause(.breakPause)
        case "breakTime": .breakTime
        case "completed": .completed
        default: .standBy
        }
    }
    var name:String{
        switch self{
        case .completed: "completed"
        case .standBy: "standBy"
        case .focus: "focus"
        case .pause(.focusPause): "pauseFocus"
        case .pause(.breakPause): "pauseBreak"
        case .breakTime: "breakTime"
        }
    }
    static func getPause(_ prevStatus:Self)->Self?{
        switch prevStatus{
        case .breakTime: return .pause(.breakPause)
        case .focus: return .pause(.focusPause)
        default:
            return nil
        }
    }
}
