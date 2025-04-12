//
//  MainController.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation
import ComposableArchitecture
extension MainFeature{
    enum Controller: CaseIterable {
        case haptic, guide, action, notification
        
        private var reducer: MainControllerProtocol {
            switch self {
                case .haptic: HapticReducer()
                case .guide: GuideReducer()
                case .action: ActionReducer()
                case .notification: NotificationReducer()
            }
        }
        
        static func makeAllReducers(state:inout MainFeature.State,act:ControllType) -> Effect<Action> {
            Effect.concatenate(
                notification.reducer.makeReducer(state: &state, act: act),
                Effect.merge([Self.haptic, .guide, .action].map{
                    $0.reducer.makeReducer(state: &state, act: act)
                })
            )
        }
    }
}
