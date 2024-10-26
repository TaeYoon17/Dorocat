//
//  ControllerReducers.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
extension MainFeature{
    func viewAction(_ state:inout State,_ act: ControllType) -> Effect<Action>{
        return ControllerReducers.makeAllReducers(state: &state, act: act)
    }
}

protocol TimerControllerProtocol{
    func makeReducer(state: inout MainFeature.State,
                     act:MainFeature.ControllType) -> Effect<MainFeature.Action>
    
    func timerFieldTapped(state:inout MainFeature.State) -> Effect<MainFeature.Action>
    func catTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func resetTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func triggerTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func triggerWillTap(state: inout MainFeature.State,type: MainFeature.HapticType) -> Effect<MainFeature.Action>
    func sessionTapped(state: inout MainFeature.State) -> Effect<MainFeature.Action>
    func resetDialogTapped(state: inout MainFeature.State,type: MainFeature.ConfirmationDialog) -> Effect<MainFeature.Action>
}
extension TimerControllerProtocol{
    func makeReducer(state: inout MainFeature.State,act: MainFeature.ControllType)->Effect<MainFeature.Action>{
        switch act{
        case .catTapped: catTapped(state: &state)
        case .resetTapped: resetTapped(state: &state)
        case .timerFieldTapped: timerFieldTapped(state: &state)
        case .triggerTapped: triggerTapped(state: &state)
        case .triggerWillTap(let type): triggerWillTap(state: &state,type: type)
        case .sessionTapped: sessionTapped(state: &state)
        case .resetDialogTapped(let dialog):
            resetDialogTapped(state: &state,type: dialog)
        }
    }
}
extension MainFeature{
    enum ControllerReducers:CaseIterable{
        case haptic,guide,action, notification
        private var myReducer: TimerControllerProtocol{
            switch self{
            case .haptic: HapticReducer()
            case .guide: GuideReducer()
            case .action: ActionReducer()
            case .notification: NotificationReducer()
            }
        }
        static func makeAllReducers(state:inout MainFeature.State,act:ControllType) -> Effect<Action>{
            return Effect.concatenate(
                Self.notification.myReducer.makeReducer(state: &state, act: act),
                Effect.merge([
                    Self.haptic,.guide,.action
                ].map{$0.myReducer.makeReducer(state: &state, act: act)})
            )
        }
    }
}
