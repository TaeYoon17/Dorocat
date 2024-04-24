//
//  TimerStatus.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
enum SleepStatus: Equatable{
    case focusSleep
    case breakSleep
}
enum TimerFeatureStatus:Equatable{
    case standBy
    case focus
    case pause
    case sleep(SleepStatus)
    case breakStandBy
    case breakTime
    case completed
}
