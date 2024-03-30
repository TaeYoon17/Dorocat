//
//  TimeFeature+TimerStatus.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
enum PauseStatus:Equatable{
    case focusPause
    case shortBreakPause
    case longBreakPause
}
enum TimerFeatureStatus:Equatable{
    case standBy
    case focus
    case pause(PauseStatus)
    case completed
    case shortBreak
    case longBreak
}
extension TimerFeatureStatus{
    static func create(name:String) -> Self{
        switch name{
        case "standBy": .standBy
        case "focus": .focus
        case "pauseFocus": .pause(.focusPause)
        case "puaseShort": .pause(.shortBreakPause)
        case "pauseLong": .pause(.longBreakPause)
        case "completed": .completed
        case "shortBreak": .shortBreak
        case "longBreak" : .longBreak
        default: .standBy
        }
    }
    var name:String{
        switch self{
        case .completed: "completed"
        case .standBy: "standBy"
        case .focus: "focus"
        case .pause(.focusPause): "pauseFocus"
        case .pause(.longBreakPause): "pauseLong"
        case .pause(.shortBreakPause): "puaseShort"
        case .shortBreak: "shortBreak"
        case .longBreak: "longBreak"
        }
    }
    static func getPause(_ prevStatus:Self)->Self?{
        switch prevStatus{
        case .longBreak: return .pause(.longBreakPause)
        case .shortBreak: return .pause(.shortBreakPause)
        case .focus: return .pause(.focusPause)
        default:
            print("pause로 변경할 필요가 없다!!")
            return nil
        }
    }
}
