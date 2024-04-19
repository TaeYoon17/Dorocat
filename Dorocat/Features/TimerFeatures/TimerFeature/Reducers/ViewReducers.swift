//
//  ViewReducers.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    func viewAction(_ state:inout State,_ act: ViewAction) -> Effect<Action>{
        switch act {
        case .timerFieldTapped:
            return self.timerFieldTapped(state: &state)
        case .circleTimerTapped:
            return self.circleTimerTapped(state: &state)
        case .catTapped:
            return self.catTapped(state: &state)
        case .resetTapped:
            return self.resetTapped(state: &state)
        case .triggerTapped:
            return self.triggerTapped(state: &state)
        }
    }
}
fileprivate extension TimerFeature{
    func timerFieldTapped(state:inout TimerFeature.State) ->  Effect<TimerFeature.Action>{
        var effects:[Effect<TimerFeature.Action>] = []
        if !state.guideInformation.onBoarding{
            state.guideInformation.onBoarding = true
            effects.append(.run(operation: {[guides = state.guideInformation] send in
                await guideDefaults.set(guide: guides)
            }))
        }
        switch state.timerStatus{
        case .focus:
            effects.append(.run { send in
                await send(.setStatus(.pause(.focusPause)))
            })
        case .pause(.focusPause):
            effects.append(.run {[count = state.count] send in
                await send(.setStatus(.focus,count:count))
                }
            )
        case .standBy: // standby일때 탭하면 세팅하는 화면으로 설정한다.
            state.timerSetting = TimerSettingFeature.State()
            effects.append(.run {[info = state.timerInformation] send in
                await send(.timerSetting(.presented(.setDefaultValues(info))))
            })
        default: break
        }
        return Effect.concatenate(effects)
    }
    func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        state.guideInformation.standByGuide = true
        return .run {[guide = state.guideInformation] send in
            await send(.setGuideState(guide))
        }
    }
    func circleTimerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .focus:
            return .run { send in
                await send(.setStatus(.pause(.focusPause)))
            }
        default: return .none
        }
    }
    func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .breakTime,.pause: return .run{ send in
            await send(.setStatus(.standBy))
        }
        default: return .none
        }
    }
    func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .standBy:
            guard state.count != 0 else {return .none}
            state.startDate = Date()
            var effects:[Effect<Action>] = [.run { send in
                await send(.setStatus(.focus))
            }]
            if !state.guideInformation.startGuide{
                var guide = state.guideInformation
                guide.startGuide = true
                effects.append(.run {[guide] send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.setGuideState(guide),animation: .easeInOut)
                    
                })
            }
            return Effect.concatenate(effects)
        case .focus: return .run { send in
            await send(.setStatus(.pause(.focusPause)))
        }
        case .pause(.focusPause):
            return .run {[count = state.count] send in
                await send(.setStatus(.focus,count: count))
            }
        case .completed: return .run{ send in
            await send(.setStatus(.standBy))
        }
        case .breakStandBy:
            state.startDate = Date()
            return .run { send in
                await send(.setStatus(.breakTime))
            }
        case .breakTime: return .concatenate([.cancel(id: CancelID.timer),
                                              .run { await $0(.setStatus(.standBy)) }])
        case .pause(.breakPause): return .none
        }
    }
}
