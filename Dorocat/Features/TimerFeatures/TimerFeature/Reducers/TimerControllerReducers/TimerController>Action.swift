//
//  TimerController>Action.swift
//  Dorocat
//
//  Created by Developer on 5/5/24.
//

import Foundation
import ComposableArchitecture
import FirebaseAnalytics
extension TimerFeature.ControllerReducers{
    struct ActionReducer: TimerControllerProtocol{
        func resetDialogTapped(state: inout TimerFeature.State, type: TimerFeature.ConfirmationDialog) -> Effect<TimerFeature.Action> {
            switch type{
            case .sessionReset:
                switch state.timerStatus{
                case .pause:
                    state.count = state.timerInformation.timeSeconds
                    return .cancel(id: TimerFeature.CancelID.timer)
                default: return .none
                }
            case .timerReset:
                switch state.timerStatus{
                case .breakTime,.pause: return .run { send in
                    await send(.setStatus(.standBy, count: nil))
                }
                default: return .none
                }
            }
        }
        
        typealias Action = TimerFeature.Action
        func timerFieldTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .standBy: // standby일때 탭하면 세팅하는 화면으로 설정한다.
                state.timerSetting = TimerSettingFeature.State()
                return .run {[info = state.timerInformation] send in
                    await send(.timerSetting(.presented(.setDefaultValues(info))))
                }
            default: return .none
            }
        }
        func sessionTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .standBy:
                state.timerSession = TimerSessionFeature.State()
                return .run {[selectedSession = state.selectedSession] send in
                    await send(.timerSession(.presented(.setSelectedSession(selectedSession))))
                }
            default: return .none
            }
        }
        func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            Analytics.logEvent("Timer Feature Cat",parameters: nil)
            switch state.timerStatus{
            case .standBy:
                if state.isProUser{
                    state.catSelect = CatSelectFeature.State()
                }else{
                    state.purchaseSheet = .init()
//                    let hapticEffect:Effect<Action> = .run { send in await haptic.impact(style: .soft) }
                    return .run{ send in
                        await send(.purchaseSheet(.presented(.initAction)))
                    }
                }
            default: break
            }
            return .none
        }
        
        func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            let isPomoMode = state.timerInformation.isPomoMode
            if isPomoMode{
                state.resetDialog = .init(title: {
                    TextState("reset button tapped")
                }, actions: {
                    ButtonState(role: .none, action: .viewAction(.resetDialogTapped(.sessionReset))) {
                        TextState("Reset This session")
                    }
                    ButtonState(role: .destructive, action: .viewAction(.resetDialogTapped(.timerReset)), label: {TextState("Reset Timer")})
                    ButtonState(role: .cancel, action: .confirmationDialog(.dismiss), label:{ TextState("Cancel")})
                }, message: nil)
            }else{
                state.resetDialog = .init(title: {
                    TextState("reset button tapped")
                }, actions: {
                    ButtonState(role: .destructive, action: .viewAction(.resetDialogTapped(.timerReset)), label: {
                        TextState("Reset Timer")
                    })
                    ButtonState(role: .cancel, action: .confirmationDialog(.dismiss), label:{ TextState("Cancel")})
                }, message: nil)
            }
            return .none
        }
        
        func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action> {
            switch state.timerStatus{
            case .standBy:
                guard state.count != 0 else {return .none}
                return .run { send in
                    await send(.setStatus(.focus,startDate: Date()))
                }
            case .focus: return .run { send in
                await send(.setStatus(.pause))
            }
            case .pause:
                return .run {[count = state.count] send in
                    await send(.setStatus(.focus,count: count))
                }
            case .completed: return .run{ send in
                await send(.setStatus(.standBy))
            }
            case .breakStandBy:
                return .run { send in
                    await send(.setStatus(.breakTime,startDate: Date()))
                }
            case .focusStandBy:
                return .run { send in
                    await send(.setStatus(.focus, startDate: Date()))
                }
            case .breakTime:
                return .run { send in
//                    await send(.setStatus(.focusStandBy))
                    await send(.setStatus(.focus,startDate: Date()))
                }.concatenate(with: .run(operation: { send in
                    await send(.setSkipInfo(true))
                    try await Task.sleep(for: .seconds(2))
                    await send(.setSkipInfo(false))
                }).animation(.easeInOut))
            case .sleep: return .none
            }
        }
        func triggerWillTap(state: inout TimerFeature.State,type: TimerFeature.HapticType) -> Effect<TimerFeature.Action>{
            return .none
        }
    }
}
