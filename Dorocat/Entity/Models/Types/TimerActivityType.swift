//
//  NotificationType.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
enum TimerActivityType:String,Identifiable,Codable{
    var id:String{ self.rawValue }
    case focusSleep
    case pause
    case breakSleep
    case standBy
}
