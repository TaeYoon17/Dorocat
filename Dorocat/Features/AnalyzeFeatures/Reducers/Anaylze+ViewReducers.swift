//
//  ViewReducers.swift
//  Dorocat
//
//  Created by Developer on 4/12/24.
//

import Foundation
import ComposableArchitecture
extension AnalyzeFeature{
    func viewAction(_ state:inout State,_ act: ViewAction) -> Effect<Action>{
        let type = state.durationType
        let date = switch (act,type){
        case (.signLeftTapped,.day): state.dayInfo.prev()
        case (.signRightTapped,.day): state.dayInfo.next()
        case (.signLeftTapped,.week): state.weekInfo.prev()
        case (.signRightTapped,.week): state.weekInfo.next()
        case (.signLeftTapped,.month): state.monthInfo.prev()
        case (.signRightTapped,.month): state.monthInfo.next()
        }
        return .run { send in
            await send(.getAllRecordsThenUpdate())
            await haptic.impact(style: .light)
        }
    }
}
