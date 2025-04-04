//
//  PomoValues.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
struct PomoValues:Equatable {
    var catType: CatType
    var isProMode:Bool = false
    var status:TimerFeatureStatus
    var information:TimerInformation?
    var cycle:Int
    var count:Int
    var sessionItem: SessionItem = .init(name: "Focus")
    var startDate:Date
}
