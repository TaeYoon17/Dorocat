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
        state: inout MainFeature.State,
        act:MainFeature.ControllType) -> Effect<MainFeature.Action>
    
    func timerFieldTapped(state:inout MainFeature.State) -> Effect<MainFeature.Action>
    func catTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func resetTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func triggerTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func triggerWillTap(state: inout MainFeature.State,type: MainFeature.HapticType) -> Effect<MainFeature.Action>
    func sessionTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func resetDialogTapped(state: inout MainFeature.State,type: MainFeature.ConfirmationDialog) -> Effect<MainFeature.Action>
}
extension MainControllerProtocol{
    func makeReducer(state: inout MainFeature.State,act: MainFeature.ControllType) -> Effect<MainFeature.Action> {
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
