//
//  MainFeature+TimerStatus.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation

extension TimerStatus{
    
    static func create(name:String) -> Self{
        switch name{
        case "standBy": .standBy
        case "focus": .focus
        case "pause": .pause
        case "breakTime": .breakTime
        case "completed": .completed
        case "breakStandBy": .breakStandBy
        case "focusSleep": .focusSleep
        case "breakSleep": .breakSleep
        default: .standBy
        }
    }
    
    var name:String{
        switch self{
        case .completed: "completed"
        case .standBy: "standBy"
        case .focus: "focus"
        case .pause: "pause"
        case .breakSleep: "breakSleep"
        case .focusSleep: "focusSleep"
        case .breakTime: "breakTime"
        case .breakStandBy: "breakStandBy"
        case .focusStandBy: "focusStandBy"
        }
    }
    
    static func getSleep(_ prevStatus:Self)->Self?{
        switch prevStatus{
        case .breakTime: return .breakSleep
        case .focus: return .focusSleep
        default:
            return nil
        }
    }
}
