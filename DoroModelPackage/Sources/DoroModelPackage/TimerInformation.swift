//
//  File.swift
//  DoroModelPackage
//
//  Created by Greem on 10/7/24.
//

import Foundation

struct TimerInformation:Codable,Equatable{
    var timeSeconds: Int = 0
    var cycle: Int = 2
    var breakTime: Int = 1
    var isPomoMode = false
}
