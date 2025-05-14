//
//  LiveActivityIntentClient.swift
//  Dorocat
//
//  Created by Developer on 5/16/24.
//

import Foundation
import AppIntents
import ActivityKit
import Combine


enum ActivityIntentManager {
    static let appGroup = "com.tistory.arpple.Dorocat.liveActivity"
    static let defaults = UserDefaults(suiteName: appGroup)
    static private let keyName = "activityIntent"
    static private let isCounting:Int = 0
    static let eventPublisher: PassthroughSubject<(prev:TimerActivityType,next:TimerActivityType), Never> = .init()
    
    static func setDefaults(type:TimerActivityType) {
        defaults?.setValue(type.rawValue, forKey: keyName)
    }
    
    
    static func focusSleepToPause() {
        let activityTypeName = defaults?.string(forKey: keyName) ?? ""
        let prevType = TimerActivityType(rawValue: activityTypeName) ?? .standBy
        let nowType = TimerActivityType.pause
        defaults?.setValue(nowType.rawValue, forKey: keyName)
        eventPublisher.send((prevType,nowType))
    }
    
    static func pauseToFocusSleep() {
        let activityTypeName = defaults?.string(forKey: keyName) ?? ""
        let prevType = TimerActivityType(rawValue: activityTypeName) ?? .standBy
        let nowType = TimerActivityType.focusSleep
        defaults?.setValue(nowType.rawValue, forKey: keyName)
        eventPublisher.send((prevType,nowType))
    }
    
    static func breakSleepToStandBy() {
        let activityTypeName = defaults?.string(forKey: keyName) ?? ""
        let prevType = TimerActivityType(rawValue: activityTypeName) ?? .standBy
        let nowType = TimerActivityType.standBy
        defaults?.setValue(nowType.rawValue, forKey: keyName)
        eventPublisher.send((prevType,nowType))
    }
    
    static func setTimerActivityType(_ type: TimerActivityType) {
        defaults?.setValue(type.rawValue, forKey: keyName)
    }
    
}
