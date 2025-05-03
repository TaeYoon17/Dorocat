//
//  TimerFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture
// MARK: -- Dorocat Tab과 Feature를 완전히 분리해서 구현해보기
extension MainFeature {
    @CasePathable
    enum ConfirmationDialog {
        case sessionReset
        case timerReset
    }
}

typealias MainEffect =  Effect<MainFeature.Action>
typealias MainState = MainFeature.State

@Reducer struct MainFeature {
    enum CancelID { case timer }
    enum Action: Equatable {
        case viewAction(ControllType)
        // 내부 로직 Action
        case initAction
        case diskInfoToMemory
        
        case setDoroStateEntity(DoroStateEntity)
        case setPomoSessionValue(SessionItem)
        case setTimerRunning(Int)
        case setSkipInfo(Bool)
        case setCatType(CatType)
        case setProUser(Bool)
        
        case timerTick
        case setStatus(TimerStatus,count: Int? = nil,startDate:Date? = nil)
        
        case timerSetting(PresentationAction<TimerSettingFeature.Action>)
        case timerSession(PresentationAction<TimerSessionFeature.Action>)
        case catSelect(PresentationAction<CatSelectFeature.Action>)
        case setAppState(DorocatFeature.AppStateType)
        case setGuideState(Guides)
        case confirmationDialog(PresentationAction<Action>)
        case purchaseSheet(PresentationAction<SettingPurchaseFeature.Action>)
    }
    @Dependency(\.doroStateDefaults) var doroStateDefaults
    @Dependency(\.pomoSession) var pomoSession
    @Dependency(\.timer.background) var timeBackground
    @Dependency(\.analyzeAPIClients) var analyzeAPI
    @Dependency(\.timer) var timer
    @Dependency(\.cat) var cat
    
    var body: some ReducerOf<Self> {
        Reduce{ state, action in
            switch action{
            case .viewAction(let viewAction):
                return self.viewAction(&state,viewAction)
            case .setAppState(let appState):
                return self.appStateRedecuer(&state,appState: appState)
            //MARK: -- 화면 전환 Action 처리
            case .timerSetting(.presented(.delegate(.setTimerInfo(let info)))):
                let progressEntity:TimerProgressEntity = TimerProgressEntity(startDate: Date(),
                                                         cycle: 0,
                                                         count: info.timeSeconds,
                                                         status: state.timerProgressEntity.status,
                                                         session: state.timerProgressEntity.session)
                let doroStateEntity:DoroStateEntity = DoroStateEntity(catType: state.catType,
                                                      isProMode: state.isProUser,
                                                      progressEntity: progressEntity,
                                                      settingEntity: info)
                return .run { send in
                    await send(.setDoroStateEntity(doroStateEntity))
                    await doroStateDefaults.setDoroStateEntity(doroStateEntity)
                }
            case .timerSession(.presented(.delegate(.setSelectSession(let session)))):
                state.timerProgressEntity.session = session
                return .none
            case .confirmationDialog(.presented(.viewAction(let viewAction))):
                return self.viewAction(&state,viewAction)
            case .timerSetting, .timerSession, .catSelect, .confirmationDialog, .purchaseSheet:
                return .none
            //MARK: --  내부 로직 Action 처리
            case .timerTick: return self.timerTick(state: &state)
            case .setStatus(let status,let count,let startDate):
                return setTimerStatus(state: &state, status: status,count: count,startDate: startDate)
            case .setTimerRunning(let count):
                state.timerProgressEntity.count = count
                return .run(priority: .high) { send in
                    for try await _ in timer.tickEventStream(){
                        await send(.timerTick)
                    }
                }.cancellable(id: CancelID.timer)
            case .initAction:
                if !state.isAppLaunched {
                    state.isAppLaunched = true
                    return Effect.concatenate(
                        .run{ send in
                            let savedValues:DoroStateEntity = await doroStateDefaults.getDoroStateEntity();
                            await send(.setDoroStateEntity(savedValues)) // 디스크에 저장된 값을 State에 보냄
                            await send(.diskInfoToMemory)
                        }, .run{ send in
                            for await event in await cat.catEventStream(){
                                switch event{
                                    case .updated(let catType): await send(.setCatType(catType))
                                }
                            }
                        })
                }else{ return .none }
            case .diskInfoToMemory:
                return .run { send in
                    do {
                        try await analyzeAPI.initAction()
                    } catch {
                        assertionFailure("analyzeAPI 에러!!")
                    }
                    await awakeTimer(send)
                }
            // 외부에서 받은 setDoroStateEntity entity를 적용시킨다.
            case .setDoroStateEntity(let doroStateEntity):
                state.timerSettingEntity = doroStateEntity.settingEntity
                state.timerProgressEntity = doroStateEntity.progressEntity
                state.catType = doroStateEntity.catType
                state.isProUser = doroStateEntity.isProMode
                return .none
            case .setGuideState(let guides):
                state.guideInformation = guides
                return .none
            case .setPomoSessionValue(let sessionItem):
                state.timerProgressEntity.session = sessionItem
                return .none
            case .setSkipInfo(let skipInfo):
                state.isSkipped = skipInfo
                return .none
            case .setCatType(let type):
                state.catType = type
                return .none
            case .setProUser(let isProUser):
                state.isProUser = isProUser
                return .none
            }
        }
        .ifLet(\.$timerSetting, action: \.timerSetting){ TimerSettingFeature() }
        .ifLet(\.$timerSession, action: \.timerSession){ TimerSessionFeature() }
        .ifLet(\.$catSelect, action: \.catSelect){ CatSelectFeature() }
        .ifLet(\.$resetDialog, action: \.confirmationDialog)
        .ifLet(\.$purchaseSheet, action: \.purchaseSheet){ SettingPurchaseFeature() }
    }
}
