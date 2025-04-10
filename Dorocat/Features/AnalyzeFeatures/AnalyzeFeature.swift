//
//  AnalyzeFeature.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import Foundation
import ComposableArchitecture
import GreemSwiftPackage

@Reducer struct AnalyzeFeature{
    
    @ObservableState struct State: Equatable{
        var durationType: DurationType = .day
        var dayInfo = DayInformation()
        var weekInfo = WeekInformation()
        var monthInfo = MonthInformation()
        var timerRecordList: IdentifiedArrayOf<TimerRecordItem>{
            switch durationType {
            case .day: dayInfo.timerRecordList
            case .week: weekInfo.timerRecordList
            case .month: monthInfo.timerRecordList
            }
        }
        var isLaunched = false
    }
    
    enum Action: Equatable{
        case viewAction(ViewAction)
        case selectDuration(DurationType)
        case setDurationType(DurationType)
        case initAnalyzeFeature
        case getAllRecordsThenUpdate(DurationType? = nil)
        case updateRecords([TimerRecordItem], type:DurationType? = nil)
    }
    
    @DBActor @Dependency(\.analyzeAPIClients) var apiClient
    @Dependency(\.haptic) var haptic
    @Dependency(\.pomoSession) var session
    
    enum CancelID{ case dbCancel }
    
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .viewAction(let action): return self.viewAction(&state, action)
            case .selectDuration(let duartionType): return selectDuration(&state, duartionType)
            case .setDurationType(let durationType):
                state.durationType = durationType
                return .run { send in
                    await haptic.impact(style: .light)
                }
            case .initAnalyzeFeature:
                if !state.isLaunched{
                    state.isLaunched = true
                    return .run(operation: {send in
                        await DurationType.allCases.asyncForEach { type in
                            await send(.getAllRecordsThenUpdate(type))
                        }
                        for try await event in await apiClient.eventAsyncStream(){
                            switch event{
                            case .append:
                                await send(.getAllRecordsThenUpdate())
                            }
                        }
                    }).cancellable(id: CancelID.dbCancel)
                }
                return .none
            case .updateRecords(let lists,let givenType): return updateRecords(&state, type: givenType, lists: lists)
            case .getAllRecordsThenUpdate(let givenType): return getAllRecordsThenUpdate(&state, type: givenType)
            }
        }
    }
}
extension AnalyzeAPIs{
    func getAnalyzeValue(date:Date,durationType: DurationType) async throws ->  [TimerRecordItem] {
        return  switch durationType{
        case .day: try await self.get(day: date)
        case .month: try await self.get(monthDate: date)
        case .week: try await self.get(weekDate: date)
        }
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
