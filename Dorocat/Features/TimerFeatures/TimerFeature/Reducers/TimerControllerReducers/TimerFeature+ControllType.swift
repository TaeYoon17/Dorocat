//
//  TimerFeature+Action.swift
//  Dorocat
//
//  Created by Developer on 3/28/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature{
    enum ControllType:Equatable{
        case timerFieldTapped
        case catTapped
        case resetTapped
        case triggerTapped
        case triggerWillTap
        case sessionTapped
    }
}
