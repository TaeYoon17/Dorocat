//
//  TimerFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

enum TimerFeatureStatus{
    case standBy
    case pomoing
    case pause
    case completed
    case shortBreak
    case longBreak
}

struct TimerInformation:Codable,Equatable{
    var timeSeconds: Int = 0
    var cycle: Int = 0
    var shortBreak: Int = 0
    var longBreak: Int = 0
    var isPomoMode = false
    
}
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
        case setTimerRunning(Int)
        case timerTick
        case setStatus(TimerFeatureStatus,isRequiredSetTimer: Bool = true)
        case timerSetting(PresentationAction<TimerSettingFeature.Action>)
        case setAppState(DorocatFeature.AppStateType)
    }
    @Dependency(\.pomoDefaults) var pomoDefaults
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
                state.timerSetting = nil
                return .none
            case .timerSetting(.presented(.delegate(.setTimerInfo(let info)))):
                state.timerInformation = info
                state.cycle = 0
                state.shortBreak = info.shortBreak
                state.longBreak = info.longBreak
                state.count = info.timeSeconds
                return .none
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
                print("state 전파...")
                let prevState = state.appState
                state.appState = appState
                switch appState{
                case .active:
                    // background 시간 없애기
                    return .run { send in
                        await timeBackground.set(date: nil)
                    }
                case .inActive:
                    if prevState == .background{
                        // 현재 시간과 background 시간 비교...
                        let prevTimerState = state.timerStatus
                        let prevCount = state.count
                        let prevCycle = state.cycle
                        let isPomo = state.timerInformation.isPomoMode
                        let targetCycle = state.timerInformation.cycle
                        let targetLongBreak = state.timerInformation.longBreak
                        return .run { send in
                            guard let prevDate = await timeBackground.date else {return }
                            let difference = Int(Date().timeIntervalSince(prevDate))
                            await timeBackground.set(date: nil)
                            print("timeBackground 실행해보기 \(difference)")
//                            let resetTime = difference - prevCount
                            if prevCount - difference >= 0 {
                                await send(.setTimerRunning(prevCount - difference))
                            }else{
                                if isPomo{
                                    let restCount = difference - prevCount
                                    var nowCycle = prevCycle + 1
                                    if nowCycle >= targetCycle{ // 사이클 자체를 다 돌았다...
                                        let isCompletedLongBreak = targetLongBreak - restCount <= 0
                                        if isCompletedLongBreak{
                                            await send(.setStatus(.completed))
                                        }else{
                                            await send(.setStatus(.longBreak, isRequiredSetTimer: false))
                                            await send(.setTimerRunning(targetLongBreak - restCount))
                                        }
                                    }else{
                                        let restCycle = targetCycle - nowCycle
                                        
                                    }
                                }else{
                                    await send(.setStatus(.completed))
                                }
                            }
                        }
                    }
                    print("inActive")
                    // background 시간 없애기
                    return .run { send in
                        await timeBackground.set(date: nil)
                    }
                case .background:
                    print("background")
                    return Effect.concatenate([
                        .cancel(id:CancelID.timer),
                        .run { send in
                            await timeBackground.set(date: Date())
                        }
                    ])
                }
            case .setTimerRunning(let count):
                state.count = count
                return .run{ send in
                    while true{
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }.cancellable(id: CancelID.timer)
            }
        }
        .ifLet(\.$timerSetting, action: \.timerSetting){
            TimerSettingFeature()
        }
    }
}
