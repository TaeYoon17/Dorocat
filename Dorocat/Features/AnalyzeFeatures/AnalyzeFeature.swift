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
        var timerRecordList: IdentifiedArrayOf<TimerRecordItem> = []
        var totalTime:String = ""
        var isLaunched = false
    }
    enum Action: Equatable{
        case leftArrowTapped
        case rightArrowTapped
        case setDurationType(DurationType)
        case initAnalyzeFeature
        case updateTimerRecordList([TimerRecordItem])
        case updateTotalTime(Double)
    }
    @DBActor @Dependency(\.analyzeAPIClients) var apiClient
    enum CancelID{
        case dbCancel
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .leftArrowTapped:
                return .none
            case .rightArrowTapped:
                return .none
            case .setDurationType(let durationType):
                state.durationType = durationType
                return .none
            case .initAnalyzeFeature:
                if !state.isLaunched{
                    state.isLaunched = true
                    return .run(operation: { send in
                        try await self.getDatabaseValueAndUpdate(sender: send)
                        for try await event in await apiClient.eventAsyncStream(){
                            switch event{
                            case .append:
                                try await self.getDatabaseValueAndUpdate(sender: send)
                            }
                        }
                    }).cancellable(id: CancelID.dbCancel)
                }else{
                    return .none
                }
                
            case .updateTimerRecordList(let lists):
                state.timerRecordList.removeAll()
                state.timerRecordList.append(contentsOf: lists)
                return .none
            case .updateTotalTime(let time):
                // 여기 수정사항 - Double 정도의 숫자 범위를 Int로 변환해도 문제가 없나?
                state.totalTime = "\(Int(time) / 60)h \(Int(time) % 60)m"
                return .none
            }
        }
    }
    func getDatabaseValueAndUpdate(sender send: Send<AnalyzeFeature.Action>) async throws {
        let list = try await apiClient.get(day: Date())
        await send(.updateTimerRecordList(list))
        await send(.updateTotalTime(apiClient.totalFocusTime))
    }
}
