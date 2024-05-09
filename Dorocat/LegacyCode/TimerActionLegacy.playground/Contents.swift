//
//  ViewReducers.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture


fileprivate extension TimerFeature{
    //MARK: -- TimerFieldTapped Reducer
    func timerFieldTapped(state:inout TimerFeature.State) ->  Effect<TimerFeature.Action>{
        var effects:[Effect<TimerFeature.Action>] = []
        if !state.guideInformation.onBoarding{
            state.guideInformation.onBoarding = true
            effects.append(.run(operation: {[guides = state.guideInformation] send in
                await guideDefaults.set(guide: guides)
            }).merge(with: .run(operation: { send in
                await haptic.impact(style: .soft)
            })))
        }
        switch state.timerStatus{
        case .standBy: // standby일때 탭하면 세팅하는 화면으로 설정한다.
            state.timerSetting = TimerSettingFeature.State()
            effects.append(.run {[info = state.timerInformation] send in
                await send(.timerSetting(.presented(.setDefaultValues(info))))
            }.merge(with: .run(operation: { send in
                await haptic.impact(style: .soft)
            })))
        default: effects.append(.run(operation: { send in
            await haptic.impact(style: .rigid,intensity: 0.7)
        }))
        }
        return Effect.concatenate(effects)
    }
    //MARK: -- Cat Tapped Reducer
    func catTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        let hapticEffect:Effect<Action> = .run {[status = state.timerStatus] send in
            switch status{
            case .breakTime,.focus: await haptic.impact(style: .rigid,intensity: 0.7)
            default: break
            }
        }
        return hapticEffect
    }
    //MARK: -- Circle Timer Tapped Reducer
    /*
    func circleTimerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .focus:
            return .run { send in
                await send(.setStatus(.pause))
            }.merge(with: .run(operation: { send in
                await haptic.impact(style: .rigid,intensity: 0.7)
            }))
        case .breakTime: return .run { send in
            await haptic.impact(style: .rigid,intensity: 0.7)
        }
        default: return .none
        }
    }
     */
    func resetTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .breakTime,.pause: return .run{ send in
            await send(.setStatus(.standBy))
        }.merge(with: .run(operation: { send in
            await haptic.notification(type: .warning)
        }))
        default: return .none
        }
    }
    func triggerTapped(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        let hapticEffect:Effect<Action> = .run { _ in await haptic.impact(style: .light) }
        switch state.timerStatus{
        case .standBy:
            guard state.count != 0 else {return .none}
            state.startDate = Date()
            state.guideInformation.standByGuide = true
            var effects:[Effect<Action>] = [hapticEffect,.run { send in
                await send(.setStatus(.focus))
            },.run {[guide = state.guideInformation] send in
                await send(.setGuideState(guide))
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
            await send(.setStatus(.pause))
        }.merge(with: hapticEffect)
        case .pause:
            return .run {[count = state.count] send in
                await send(.setStatus(.focus,count: count))
            }.merge(with: hapticEffect)
        case .completed: return .run{ send in
            await send(.setStatus(.standBy))
        }.merge(with: hapticEffect)
        case .breakStandBy:
            state.startDate = Date()
            return .run { send in
                await send(.setStatus(.breakTime))
            }.merge(with: hapticEffect)
        case .breakTime: return .concatenate([.cancel(id: CancelID.timer),
                                              .run { await $0(.setStatus(.standBy)) }]).merge(with: hapticEffect)
        case .sleep: return .none
        }
    }
    
    func triggerWillTap(state: inout TimerFeature.State) -> Effect<TimerFeature.Action>{
        switch state.timerStatus{
        case .completed,
                .breakStandBy,
                .breakTime,
                .standBy,
                .focus,.pause:
            return .run { send in
                await haptic.impact(style: .heavy)
            }
        default:
            return .none
        }
    }
}
