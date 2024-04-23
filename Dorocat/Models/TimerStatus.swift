//
//  TimerStatus.swift
//  Dorocat
//
//  Created by Developer on 4/23/24.
//

import Foundation
enum PauseStatus:Equatable{
    case focusPause
    case breakPause
}
enum TimerFeatureStatus:Equatable{
    case standBy
    case focus
    case pause(PauseStatus)
    case breakStandBy
    case breakTime
    case completed
}
