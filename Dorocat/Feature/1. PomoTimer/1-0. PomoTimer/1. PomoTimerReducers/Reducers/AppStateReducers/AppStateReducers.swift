//
//  AppStateReducers.swift
//  Dorocat
//
//  Created by Developer on 4/9/24.
//

import Foundation
import ComposableArchitecture

extension MainFeature{
    func appStateRedecuer(_ state: inout MainFeature.State,appState: DorocatFeature.AppStateType)-> Effect<Action>{
        let prevState = state.appState
        state.appState = appState
        let state = state
        return Effect.merge(AppStateReducers.makeAllReducer(capturedState: state,
                                                                  prevAppState: prevState,
                                                                  nowAppState: appState)
        )
    }
    
}
extension MainFeature{
    enum AppStateReducers:CaseIterable{
        typealias AppState = DorocatFeature.AppStateType
        typealias State = MainFeature.State
        case notification,pomoTimer,activity
        private var myReducer:AppStateReducerProtocol{
            switch self{
            case .activity: LiveActivityReducer()
            case .notification: NotificationReducer()
            case .pomoTimer: TimerReducer()
            }
        }
        static func makeAllReducer(capturedState: State,prevAppState:AppState,nowAppState:AppState)->[Effect<Action>]{
            return [Self.notification,.activity,.pomoTimer].map{$0.myReducer.makeReducer(capturedState: capturedState,
                                                       prevAppState: prevAppState,
                                                       nextAppState: nowAppState)
            }
        }
        func makeReducer(capturedState: State,prevAppState:AppState,nowAppState:AppState)->Effect<Action>{
            myReducer.makeReducer(capturedState: capturedState,
                                  prevAppState: prevAppState,
                                  nextAppState: nowAppState)
        }
    }
}
protocol AppStateReducerProtocol{
    func makeReducer(capturedState state: MainFeature.State,
                     prevAppState:DorocatFeature.AppStateType,
                     nextAppState:DorocatFeature.AppStateType)->Effect<MainFeature.Action>
}
