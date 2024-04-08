//
//  AnalyzeFeature.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift
enum AnalyzeDateType{
    case day
    case week
    case month
}
@Reducer struct AnalyzeFeature{
    @ObservableState struct State:Equatable{
        var timerRecordList: IdentifiedArrayOf<TimerRecordItem> = []
        var totalTime:String = ""
    }
    enum Action: Equatable{
        case leftArrowTapped
        case rightArrowTapped
        case setAnalyzeTypeSegment(AnalyzeDateType)
        case initShoppingLists
        case updateTimerRecordList([TimerRecordItem])
        case updateTotalTime(Double)
    }
    @DBActor @Dependency(\.analyzeAPIClients) var apiClient
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .leftArrowTapped:
                return .none
            case .rightArrowTapped:
                return .none
            case .setAnalyzeTypeSegment(_):
                return .none
            case .initShoppingLists:
                return .run {@DBActor send in
                    do{
                        try await apiClient.initAction()
                        let list = try await apiClient.get(day: Date())
                        await send(.updateTimerRecordList(list))
                        await send(.updateTotalTime(apiClient.totalFocusTime))
                    }catch{
                        print(error)
                    }
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
}
