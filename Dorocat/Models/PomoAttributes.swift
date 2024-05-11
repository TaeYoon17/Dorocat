//
//  ActivityValue.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
import ActivityKit
struct PomoAttributes:ActivityAttributes{
    struct ContentState:Codable,Hashable{
        var count:Int = 0
        var endTime:Int = 0
    }
}
enum Status: String,CaseIterable,Codable,Equatable{
    case received = "eraser"
    case progress = "plus.fill"
    case ready = "pencil.circle.fill"
}
