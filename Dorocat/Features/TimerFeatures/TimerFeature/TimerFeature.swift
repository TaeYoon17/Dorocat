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
        case viewAction(ControllType)
        // 내부 로직 Action
        case initAction
        case diskInfoToMemory
        case setDefaultValues(PomoValues)
        case setPomoSessionValue(SessionItem)
        case setTimerRunning(Int)
        case timerTick
        case setStatus(TimerFeatureStatus,count: Int? = nil,startDate:Date? = nil)
        case timerSetting(PresentationAction<TimerSettingFeature.Action>)
        case timerSession(PresentationAction<TimerSessionFeature.Action>)
        case catSelect(PresentationAction<CatSelectFeature.Action>)
        case setAppState(DorocatFeature.AppStateType)
        case setGuideState(Guides)
    }
    @Dependency(\.pomoDefaults) var pomoDefaults
    @Dependency(\.pomoSession) var pomoSession
    @Dependency(\.timer.background) var timeBackground
    @Dependency(\.analyzeAPIClients) var analyzeAPI
    @Dependency(\.timer) var timer
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .viewAction(let viewAction): return self.viewAction(&state,viewAction)
            case .setAppState(let appState): return self.appStateRedecuer(&state,appState: appState)
            //MARK: -- 화면 전환 Action 처리
            case .timerSetting(.presented(.delegate(.cancel))): return .none
            case .timerSetting(.presented(.delegate(.setTimerInfo(let info)))):
                let count = info.timeSeconds
                let pomoValues = PomoValues(catType: state.catType, status: state.timerStatus, information: info, cycle: 0, count: count,startDate: state.startDate)
                return .run { send in
                    await send(.setDefaultValues(pomoValues))
                    await pomoDefaults.setAll(pomoValues)
                }
            case .timerSetting: return .none
            case .timerSession(.presented(.delegate(.setSelectSession(let session)))):
                state.selectedSession = session
                return .none
            case .timerSession(.presented(.delegate(.cancel))): return .none
            case .timerSession: return .none
            case .catSelect(.presented(.delegate(.setCatType(let type)))):
                print("delegate 발생 \(type)")
                state.catType = type
                return .none
            case .catSelect: return .none
            //MARK: --  내부 로직 Action 처리
            case .timerTick: return self.timerTick(state: &state)
            case .setStatus(let status,let count,let startDate):
                return setTimerStatus(state: &state, status: status,count: count,startDate: startDate)
            case .setTimerRunning(let count):
                state.count = count
                return .run(priority: .high) { send in
                    for try await _ in timer.tickEventStream(){ await send(.timerTick) }
                }.cancellable(id: CancelID.timer)
            case .initAction:
                if !state.isAppLaunched {
                    state.isAppLaunched = true
                    return Effect.concatenate(
                        .run{ send in
                            let savedValues:PomoValues = await pomoDefaults.getAll() // 디스크에 저장된 값
                            let sessionItem = await pomoSession.selectedItem
                            await send(.setDefaultValues(savedValues)) // 디스크에 저장된 값을 State에 보냄
                            await send(.setPomoSessionValue(sessionItem))
                            await send(.diskInfoToMemory)
                        })
                }else{ return .none }
            case .diskInfoToMemory:
                return .run{ send in
                    try await analyzeAPI.initAction()
                    await awakeTimer(send)
                }
            case .setDefaultValues(let value):
                guard let info = value.information else {
                    state.timerInformation = TimerInformation.defaultCreate()
                    state.count = 25 * 60
                    state.timerStatus = value.status
                    state.cycle = value.cycle
                    state.catType = value.catType
                    return .none
                }
                state.timerInformation = info
                state.count = value.count
                state.cycle = value.cycle
                state.catType = value.catType
                state.timerStatus = value.status
                return .none
            case .setGuideState(let guides):
                state.guideInformation = guides
                return .none
            case .setPomoSessionValue(let sessionItem):
                state.selectedSession = sessionItem
                return .none
            }
        }
        .ifLet(\.$timerSetting, action: \.timerSetting){
            TimerSettingFeature()
        }
        .ifLet(\.$timerSession, action: \.timerSession){
            TimerSessionFeature()
        }
        .ifLet(\.$catSelect, action: \.catSelect){
            CatSelectFeature()
        }
    }
}

