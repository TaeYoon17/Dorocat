//
//  ViewReducers.swift
//  Dorocat
//
//  Created by Developer on 4/12/24.
//

import Foundation
import ComposableArchitecture
extension AnalyzeFeature{
    func viewAction(_ state: inout State, _ act: ViewAction) -> Effect<Action> {
        let type = state.durationType
        switch act {
        case .editTapped(let item):
            state.editDialog = .editDialog(item: item)
            return .run { send in
                await haptic.impact(style: .light)
            }
        case .signLeftTapped:
            _ = switch type {
                case .day: state.dayInfo.prev()
                case .week: state.weekInfo.prev()
                case .month: state.monthInfo.prev()
            }
            return .run { send in
                await send(.getAllRecordsThenUpdate())
                await haptic.impact(style: .light)
            }
        case .signRightTapped:
            _ = switch type {
                case .day: state.dayInfo.next()
                case .week: state.weekInfo.next()
                case .month: state.monthInfo.next()
            }
            return .run { send in
                await send(.getAllRecordsThenUpdate())
                await haptic.impact(style: .light)
            }
        }
    }
}

extension ConfirmationDialogState where Action == AnalyzeFeature.Action.AnalyzeEdit {
    
    static func editDialog(item: TimerRecordItem) -> ConfirmationDialogState {
        .init(
            title: {
                TextState("Edit button tapped")
            }, actions: {
            ButtonState(action: .changeFocusType(item), label: {
                TextState("Change session type")
            })
            ButtonState(role: .destructive, action: .removeItem(item), label: {
                TextState("Delete this record")
            })
            ButtonState(role: .cancel, label:{
                TextState("Cancel")
            })
        }, message: {
            TextState("Edit Record")
        })
    }
   
    
}
