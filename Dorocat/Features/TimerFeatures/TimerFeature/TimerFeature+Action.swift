//
//  TimerFeature+Action.swift
//  Dorocat
//
//  Created by Developer on 3/28/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature{
    enum ViewAction:Equatable{
        case timerFieldTapped
        case circleTimerTapped
        case catTapped
        case resetTapped
        case triggerTapped
    }
}
