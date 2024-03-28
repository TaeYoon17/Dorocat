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
    case running
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
        case timerTick
        case setStatus(TimerFeatureStatus)
        case timerSetting(PresentationAction<TimerSettingFeature.Action>)
    }
    @Dependency(\.pomoDefaults) var pomoDefaults
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
                state.cycle = info.cycle
                state.shortBreak = info.shortBreak
                state.longBreak = info.longBreak
                state.count = info.timeSeconds
                return .none
            case .timerSetting: return .none
            case .timerTick:
                return self.timerTick(state: &state)
            // 내부 로직 Action 처리
            case .setStatus(let status): return setTimer(state: &state, status: status)
            }
        }
        .ifLet(\.$timerSetting, action: \.timerSetting){
            TimerSettingFeature()
        }
    }
}
