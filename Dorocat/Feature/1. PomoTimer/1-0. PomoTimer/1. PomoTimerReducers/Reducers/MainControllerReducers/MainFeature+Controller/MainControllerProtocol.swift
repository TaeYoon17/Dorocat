//
//  MainControllerProtocol.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation
import ComposableArchitecture
protocol MainControllerProtocol{
    func makeReducer(
        state: inout PomoTimerFeature.State,
        act:PomoTimerFeature.ControllType) -> Effect<PomoTimerFeature.Action>
    
    func timerFieldTapped(state:inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action>
    func catTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action>
    func resetTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action>
    func triggerTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action>
    func triggerWillTap(
        state: inout PomoTimerFeature.State,
        type: PomoTimerFeature.HapticType
    ) -> Effect<PomoTimerFeature.Action>
    func sessionTapped(state: inout PomoTimerFeature.State) -> Effect<PomoTimerFeature.Action>
    func resetDialogTapped(
        state: inout PomoTimerFeature.State,
        type: PomoTimerFeature.ConfirmationDialog
    ) -> Effect<PomoTimerFeature.Action>
}


extension MainControllerProtocol{
    func makeReducer(state: inout PomoTimerFeature.State,act: PomoTimerFeature.ControllType) -> Effect<PomoTimerFeature.Action> {
        switch act {
            case .catTapped: catTapped(state: &state)
            case .resetTapped: resetTapped(state: &state)
            case .timerFieldTapped: timerFieldTapped(state: &state)
            case .triggerTapped: triggerTapped(state: &state)
            case .triggerWillTap(let type): triggerWillTap(state: &state,type: type)
            case .sessionTapped: sessionTapped(state: &state)
            case .resetDialogTapped(let dialog): resetDialogTapped(state: &state,type: dialog)
        }
    }
}
