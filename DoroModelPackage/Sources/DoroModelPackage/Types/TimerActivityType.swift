//
//  File.swift
//  DoroModelPackage
//
//  Created by Greem on 10/7/24.
//

import Foundation

enum TimerActivityType:String,Identifiable,Codable{
    var id:String{ self.rawValue }
    case focusSleep
    case pause
    case breakSleep
    case standBy
}
