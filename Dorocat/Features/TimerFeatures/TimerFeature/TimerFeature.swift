//
//  TimerFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture
// MARK: -- Dorocat Tab과 Feature를 완전히 분리해서 구현해보기
@Reducer struct TimerFeature{
    enum CancelID { case timer }
    enum Action:Equatable{
        case viewAction(ViewAction)
        // 내부 로직 Action
        case initAction
        case setDefaultValues(PomoValues)
        case setTimerRunning(Int)
        case timerTick
        case setStatus(TimerFeatureStatus,count: Int? = nil)
        case timerSetting(PresentationAction<TimerSettingFeature.Action>)
        case setAppState(DorocatFeature.AppStateType)
        case setGuideState(Guides)
    }
    @Dependency(\.pomoDefaults) var pomoDefaults
    @Dependency(\.guideDefaults) var guideDefaults
    @Dependency(\.timeBackground) var timeBackground
    @Dependency(\.analyzeAPIClients) var analyzeAPI
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .viewAction(let viewAction): return self.viewAction(&state,viewAction)
            case .setAppState(let appState): return self.appStateRedecuer(&state,appState: appState)
            //MARK: -- 화면 전환 Action 처리
            case .timerSetting(.presented(.delegate(.cancel))):
                return .none
            case .timerSetting(.presented(.delegate(.setTimerInfo(let info)))):
                let count = info.timeSeconds
                let pomoValues = PomoValues(status: state.timerStatus, information: info, cycle: 0, count: count,startDate: state.startDate)
                return .run { send in
                    await send(.setDefaultValues(pomoValues))
                    await pomoDefaults.setAll(pomoValues)
                }
            case .timerSetting: return .none
            case .timerTick: return self.timerTick(state: &state)
                // 내부 로직 Action 처리
            case .setStatus(let status,let count): return setTimerStatus(state: &state, status: status,count: count)
            case .setTimerRunning(let count):
                state.count = count
                return .run{ send in
                    while true{
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }.cancellable(id: CancelID.timer)
            case .initAction:
                if !state.isAppLaunched {
                    state.isAppLaunched = true
                    return Effect.concatenate(
                        .run{ send in
                            let savedValues:PomoValues = await pomoDefaults.getAll() // 디스크에 저장된 값
                            await send(.setDefaultValues(savedValues)) // 디스크에 저장된 값을 State에 보냄
                        }
                        ,diskTimerInfoToMemory)
                }else{ return .none }
            case .setDefaultValues(let value):
                print("default Values \(value)")
                guard let info = value.information else {
                    state.timerInformation = TimerInformation.defaultCreate()
                    state.count = 25 * 60
                    state.timerStatus = value.status
                    state.cycle = value.cycle
                    return .none
                }
                state.timerInformation = info
                state.count = value.count
                state.cycle = value.cycle
                state.timerStatus = value.status
                return .none
            case .setGuideState(let guides):
                state.guideInformation = guides
                return .none
            }
        }
        .ifLet(\.$timerSetting, action: \.timerSetting){
            TimerSettingFeature()
        }
    }
}
