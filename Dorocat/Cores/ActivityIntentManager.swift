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
enum TimerActivityType:String,Identifiable,Codable{
    var id:String{ self.rawValue }
    case focusSleep
    case pause
    case breakSleep
    case standBy
}

enum ActivityIntentManager{
    static let appGroup = "com.tistory.arpple.Dorocat.liveActivity"
    static let defaults = UserDefaults(suiteName: appGroup)
    static private let keyName = "activityIntent"
    static let eventPublisher: PassthroughSubject<(prev:TimerActivityType,next:TimerActivityType),Never> = .init()
    static func setDefaults(type:TimerActivityType){
        defaults?.setValue(type.rawValue, forKey: keyName)
    }
    static func focusSleepToPause(){
        print("여기에요 여기")
        let activityTypeName = defaults?.string(forKey: keyName) ?? ""
        let prevType = TimerActivityType(rawValue: activityTypeName) ?? .standBy
        let nowType = TimerActivityType.pause
        defaults?.setValue(nowType.rawValue, forKey: keyName)
        eventPublisher.send((prevType,nowType))
    }
    static func pauseToFocusSleep(){
        let activityTypeName = defaults?.string(forKey: keyName) ?? ""
        let prevType = TimerActivityType(rawValue: activityTypeName) ?? .standBy
        let nowType = TimerActivityType.focusSleep
        defaults?.setValue(nowType.rawValue, forKey: keyName)
        eventPublisher.send((prevType,nowType))
    }
    static func breakSleepToStandBy(){
        let activityTypeName = defaults?.string(forKey: keyName) ?? ""
        let prevType = TimerActivityType(rawValue: activityTypeName) ?? .standBy
        let nowType = TimerActivityType.standBy
        defaults?.setValue(nowType.rawValue, forKey: keyName)
        eventPublisher.send((prevType,nowType))
    }
}
