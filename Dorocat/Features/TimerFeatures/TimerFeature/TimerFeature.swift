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
        // View에 보이는 그대로 Action
        case timerFieldTapped
        case circleTimerTapped
        case catTapped
        case resetTapped
        case completeTapped
        // 내부 로직 Action
        case initAction
        case setDefaultValues(PomoValues)
        case setTimerRunning(Int)
        case timerTick
        case setStatus(TimerFeatureStatus,isRequiredSetTimer: Bool = true)
        case timerSetting(PresentationAction<TimerSettingFeature.Action>)
        case setAppState(DorocatFeature.AppStateType)
        case setGuideState(Guides)
    }
    @Dependency(\.pomoDefaults) var pomoDefaults
    @Dependency(\.guideDefaults) var guideDefaults
    @Dependency(\.timeBackground) var timeBackground
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
                // 뷰 버튼, Field... Action 처리
            case .timerFieldTapped: return self.timerFieldTapped(state: &state)
            case .circleTimerTapped: return self.circleTimerTapped(state: &state)
            case .catTapped: return self.catTapped(state: &state)
            case .resetTapped: return self.resetTapped(state: &state)
            case .completeTapped: return self.completeTapped(state: &state)
                // 화면 전환 Action 처리
            case .timerSetting(.presented(.delegate(.cancel))):
                //                state.timerSetting = nil
                return .none
            case .timerSetting(.presented(.delegate(.setTimerInfo(let info)))):
                let count = info.timeSeconds
                let pomoValues = PomoValues(status: state.timerStatus, information: info, cycle: 0, count: count)
                return .run { send in
                    await send(.setDefaultValues(pomoValues))
                    await pomoDefaults.setAll(pomoValues)
                }
            case .timerSetting: return .none
            case .timerTick: return self.timerTick(state: &state)
                // 내부 로직 Action 처리
            case .setStatus(let status,let isRequiredSetTimer):
                state.timerStatus = status
                if isRequiredSetTimer{
                    return setTimer(state: &state, status: status)
                }else{
                    return .none
                }
            case .setAppState(let appState):
                let prevState = state.appState
                state.appState = appState
                switch appState{
                case .active:// background 시간 없애주기...
                    return .run { send in
                        await timeBackground.set(date: nil)
                }
                case .inActive:
                    if prevState == .background{ // 현재 시간과 background 시간 비교...
                        return diskTimerInfoToMemory
                    }else{
            // 현재 진행상황 저장 - background로 이동시 무조건 타이머 상태는 pause가 되도록 설정한다.
                        let prevStatus = state.timerStatus
                        let pauseStatus = TimerFeatureStatus.getPause(state.timerStatus) ?? state.timerStatus
                        let values = PomoValues(status: pauseStatus, information: state.timerInformation, cycle: state.cycle, count: state.count)
                        return .run { send in
                            await timeBackground.set(date: Date())
                            await timeBackground.set(timerStatus: prevStatus)
                            await send(.setStatus(pauseStatus, isRequiredSetTimer: true))
                            await pomoDefaults.setAll(values)
                        }
                    }
                case .background: return .none
                }
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
                    return diskTimerInfoToMemory
                }else{ return .none }
            case .setDefaultValues(let value):
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
