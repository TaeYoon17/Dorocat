//
//  TimeFeature+TimerStatus.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation

extension TimerFeatureStatus{
    static func create(name:String) -> Self{
        switch name{
        case "standBy": .standBy
        case "focus": .focus
        case "pause": .pause
        case "breakTime": .breakTime
        case "completed": .completed
        case "breakStandBy": .breakStandBy
        case "focusSleep": .sleep(.focusSleep)
        case "breakSleep": .sleep(.breakSleep)
        default: .standBy
        }
    }
    var name:String{
        switch self{
        case .completed: "completed"
        case .standBy: "standBy"
        case .focus: "focus"
        case .pause: "pause"
        case .sleep(.breakSleep): "breakSleep"
        case .sleep(.focusSleep): "focusSleep"
        case .breakTime: "breakTime"
        case .breakStandBy: "breakStandBy"
        }
    }
    static func getSleep(_ prevStatus:Self)->Self?{
        switch prevStatus{
        case .breakTime: return .sleep(.breakSleep)
        case .focus: return .sleep(.focusSleep)
        default:
            return nil
        }
    }
}
