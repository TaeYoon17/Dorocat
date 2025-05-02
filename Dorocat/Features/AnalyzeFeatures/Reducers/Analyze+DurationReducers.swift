//
//  Analyze+DurationReducers.swift
//  Dorocat
//
//  Created by Developer on 4/13/24.
//

import Foundation
import ComposableArchitecture

extension AnalyzeFeature{
    func selectDuration(_ state: inout State, _ type: DurationType) -> Effect<Action>{
        return .run { send in
            await send(.getAllRecordsThenUpdate(type))
            await send(.setDurationType(type))
        }
    }
    // 가져온 리스트를 State에 적용하는 메서드
    func updateRecords(_ state: inout State,type givenType: DurationType?,lists: [TimerRecordItem]) -> Effect<Action>{
        let type = givenType ?? state.durationType
        switch type{
        case .day:
            state.dayInfo.timerRecordList.removeAll()
            state.dayInfo.timerRecordList.append(contentsOf: lists)
        case.month:
            state.monthInfo.timerRecordList.removeAll()
            state.monthInfo.timerRecordList.append(contentsOf: lists)
        case .week:
            state.weekInfo.timerRecordList.removeAll()
            state.weekInfo.timerRecordList.append(contentsOf: lists)
        }
        return .none
    }
    // 요청한 타입에 맞게 Dependency에서 가져오고 State에 적용하는 메서드
    func getAllRecordsThenUpdate(_ state:inout State, type givenType: DurationType?) -> Effect<Action>{
        let type = givenType ?? state.durationType
        let date = type.dateInfo(state: &state)
        return .run { send in
            let lists = try await apiClient.getAnalyzeValue(date: date, durationType: type)
            await send(.updateRecords(lists,type: type))
        }
    }
}
