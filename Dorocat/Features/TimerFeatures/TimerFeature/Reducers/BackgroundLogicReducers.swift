//
//  BackgroundLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature{
    var diskToMemory:Effect<TimerFeature.Action>{
        .run { send in
            // 시간 설정
            guard let prevDate = await timeBackground.date else { return }
            if Date().isOverTwoDays(prevDate: prevDate){
                await send(.setStatus(.standBy, isRequiredSetTimer: true))
                return
            }
            let difference = Int(Date().timeIntervalSince(prevDate))
            await timeBackground.set(date: nil)
            let prevStatus = await timeBackground.timerStatus
            let savedValues = await pomoDefaults.getAll()
            await send(.setDefaultValues(savedValues))
            switch (prevStatus,savedValues.status){
            case (_,.completed),(_,.standBy): break
            case (_,.focus),(_,.longBreak),(_,.shortBreak): fatalError("이게 왜 돌아가...")
            case (.pause,.pause): break
            case (.focus,.pause(.focusPause)):
                guard let info = savedValues.information else {
                    fatalError("여기에는 정보가 있어야한다.")
                }
                if info.isPomoMode{
                    await pomoTimerFocus(send, value: savedValues, diff: difference)
                }else{
                    await defaultTimerFocus(send, value: savedValues, diff: difference)
                }
            case (.shortBreak,.pause(.shortBreakPause)):
                await self.pomoTimerShort(send, value: savedValues, diff: difference)
            case (.longBreak,.pause(.longBreakPause)):
                guard let info = savedValues.information else {
                    fatalError("여기에는 정보가 있어야한다.")
                }
                await self.longBreakFocus(send, info: info, timeDiff: difference)
            default: print("알 수 없는 상태 \(prevStatus) \(savedValues.status)")
            }
        }
    }
}

//MARK: -- focus 상태일 때 처리
extension TimerFeature{
    fileprivate typealias Sender = Send<TimerFeature.Action>
    fileprivate func defaultTimerFocus(_ send: Send<TimerFeature.Action>,value:PomoValues,diff:Int) async{
        let restTime = value.count - diff
        if restTime > 0{
            await send(.setStatus(.focus, isRequiredSetTimer: false))
            await send(.setTimerRunning(restTime))
        }else{
            await send(.setStatus(.completed))
        }
    }
    fileprivate func pomoTimerFocus(_ send: Sender,value: PomoValues,diff:Int) async{
        guard let info = value.information else {fatalError("여기에는 정보가 있어야한다.")}
        var timeDiff = diff - value.count
        var cycle = value.cycle
        var newValue = value
        if timeDiff <= 0{
            await send(.setStatus(.focus, isRequiredSetTimer: false))
            await send(.setTimerRunning(value.count - diff))
        }else{
            cycle += 1
            let restCycle = info.cycle - cycle
            let cycleTime = info.timeSeconds + info.shortBreak
            if restCycle <= 0{
                // 사이클이 존재하지 않음... longBreak으로 넘어감
                await longBreakFocus(send, info: info, timeDiff: timeDiff)
            }else{ // 사이클이 존재함...
                let availableCycle = min(timeDiff / cycleTime, restCycle)
                cycle += availableCycle
                timeDiff -= availableCycle * cycleTime
                newValue.cycle = cycle
                await send(.setDefaultValues(newValue))
                if cycle == info.cycle{
                    // 사이클을 전부 소화함... longBreak으로 넘어감
                    await longBreakFocus(send, info: info, timeDiff: timeDiff)
                }else if cycle < info.cycle{ // 사이클이 남음
                    if timeDiff - info.shortBreak < 0{ // 짧은 시간을 전부 소화 못함 -> 시간 할당해야함
                        await send(.setStatus(.shortBreak, isRequiredSetTimer: false))
                        await send(.setTimerRunning(info.shortBreak - timeDiff))
                    }else{
                        timeDiff -= info.shortBreak
                        await send(.setStatus(.focus, isRequiredSetTimer: false))
                        await send(.setTimerRunning(info.timeSeconds - timeDiff))
                    }
                }else{
                    fatalError("cycle이 기존에 목표 cycle보다 크다.")
                }
            }
        }
    }
    private func longBreakFocus(_ send:Sender,info: TimerInformation,timeDiff:Int) async {
        if timeDiff - info.longBreak < 0{ // longBreak을 전부 소화하지 못 함...
            await send(.setStatus(.longBreak, isRequiredSetTimer: false))
            await send(.setTimerRunning(info.longBreak - timeDiff))
        }else{
            await send(.setStatus(.completed, isRequiredSetTimer: true))
        }
    }
}
//MARK: -- shortBreak 상태일 때 처리
extension TimerFeature{
    fileprivate func pomoTimerShort(_ send: Sender,value: PomoValues,diff: Int) async {
        guard let info = value.information else {fatalError("여기에는 정보가 있어야한다.")}
        var timeDiff = diff - value.count
        var cycle = value.cycle
        var newValue = value
        if timeDiff <= 0{
            await send(.setStatus(.shortBreak, isRequiredSetTimer: false))
            await send(.setTimerRunning(value.count - diff))
        }else{
            newValue.count = info.timeSeconds
            newValue.status = .pause(.focusPause)
            await pomoTimerFocus(send, value: newValue, diff: timeDiff)
        }
    }
}
