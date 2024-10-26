//
//  TimerFeature+Action.swift
//  Dorocat
//
//  Created by Developer on 3/28/24.
//

import Foundation
import ComposableArchitecture

extension MainFeature{
    enum HapticType:Equatable{
        case heavy
        case soft
    }
    enum ControllType:Equatable{
        case timerFieldTapped
        case catTapped
        case resetTapped
        case triggerTapped
        case triggerWillTap(HapticType = .heavy)
        case sessionTapped
        case resetDialogTapped(ConfirmationDialog)
    }
}
