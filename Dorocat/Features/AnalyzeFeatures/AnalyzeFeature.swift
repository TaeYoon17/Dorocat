//
//  AnalyzeFeature.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import Foundation
import ComposableArchitecture
@Reducer struct AnalyzeFeature{
    @ObservableState struct State:Equatable{
        var durationType: DurationType = .day
        var timerRecordList: IdentifiedArrayOf<TimerRecordItem>{
            switch durationType {
            case .day: dayInfo.timerRecordList
            case .week: weekInfo.timerRecordList
            case .month: monthInfo.timerRecordList
            }
        }
        var dayInfo = DayInformation()
        var weekInfo = WeekInformation()
        var monthInfo = MonthInformation()
        var totalTime: String = ""
        var isLaunched = false
    }
    enum Action: Equatable{
        case viewAction(ViewAction)
        case setDurationType(DurationType)
        case initAnalyzeFeature
        case updateTimerRecordList([TimerRecordItem])
        case updateTotalTime(Double)
    }
    @DBActor @Dependency(\.analyzeAPIClients) var apiClient
    enum CancelID{ case dbCancel }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .viewAction(let action): return self.viewAction(&state, action)
            case .setDurationType(let durationType):
                state.durationType = durationType
                let type = state.durationType
                let myDate:Date = type.dateInfo(state: &state)
                return .run { send in
                    try await getDatabaseValueAndUpdate(sender: send, date: myDate, durationType: type)
                }
            case .initAnalyzeFeature:
                if !state.isLaunched{
                    state.isLaunched = true
                    let type = state.durationType
                    let myDate:Date = type.dateInfo(state: &state)
                    return .run(operation: {[myDate] send in
                        try await self.getDatabaseValueAndUpdate(sender: send, date: myDate,durationType: type)
                        for try await event in await apiClient.eventAsyncStream(){
                            switch event{
                            case .append:
                                try await self.getDatabaseValueAndUpdate(sender: send,date: myDate,durationType: type)
                            }
                        }
                    }).cancellable(id: CancelID.dbCancel)
                }else{
                    return .none
                }
            case .updateTimerRecordList(let lists):
                switch state.durationType{
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
            case .updateTotalTime(let time):
                // 여기 수정사항 - Double 정도의 숫자 범위를 Int로 변환해도 문제가 없나?
                state.totalTime = "\(Int(time) / 60)h \(Int(time) % 60)m"
                return .none
            }
        }
        
    }
    func getDatabaseValueAndUpdate(sender send: Send<AnalyzeFeature.Action>,date:Date,durationType: DurationType) async throws {
        let list = switch durationType{
        case .day: try await apiClient.get(day: date)
        case .month: try await apiClient.get(monthDate: date)
        case .week: try await apiClient.get(weekDate: date)
        }
        await send(.updateTimerRecordList(list))
        await send(.updateTotalTime(apiClient.totalFocusTime))
    }
}
extension DurationType{
    func dateInfo(state: inout AnalyzeFeature.State) -> Date{
        switch self{
        case .day: state.dayInfo.date
        case .month: state.monthInfo.date
        case .week: state.weekInfo.date
        }
    }
}
