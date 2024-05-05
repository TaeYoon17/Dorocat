//
//  ControllerReducers.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    func viewAction(_ state:inout State,_ act: ControllType) -> Effect<Action>{
        return Effect.merge(ControllerReducers.makeAllReducers(state: &state, act: act))
    }
}

protocol TimerControllerProtocol{
    func makeReducer(state: inout TimerFeature.State,
                     act:TimerFeature.ControllType) -> Effect<TimerFeature.Action>
    
    func timerFieldTapped(state:inout TimerFeature.State) -> Effect<TimerFeature.Action>
    func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>
    func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>
    func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>
    func triggerWillTap(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>
}
extension TimerControllerProtocol{
    func makeReducer(state: inout TimerFeature.State,act: TimerFeature.ControllType)->Effect<TimerFeature.Action>{
        switch act{
        case .catTapped: catTapped(state: &state)
        case .resetTapped: resetTapped(state: &state)
        case .timerFieldTapped: timerFieldTapped(state: &state)
        case .triggerTapped: triggerTapped(state: &state)
        case .triggerWillTap: triggerWillTap(state: &state)
        }
    }
}
extension TimerFeature{
    enum ControllerReducers:CaseIterable{
        case haptic,guide,action
        private var myReducer: TimerControllerProtocol{
            switch self{
            case .haptic: HapticReducer()
            case .guide: GuideReducer()
            case .action: ActionReducer()
            }
        }
        static func makeAllReducers(state:inout TimerFeature.State,act:ControllType) -> [Effect<Action>]{
            Self.allCases.map { reducer in
                reducer.myReducer.makeReducer(state: &state, act: act)
            }
        }
    }
}
