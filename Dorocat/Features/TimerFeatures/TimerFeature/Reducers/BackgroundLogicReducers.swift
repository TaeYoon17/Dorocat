//
//  BackgroundLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
import ComposableArchitecture

extension TimerFeature{
    /// 앱을 시작할 때, inActive로 돌아올 때
    /// 디스크에 저장되어 남았던 데이터를 가져옴
    var diskTimerInfoToMemory:Effect<TimerFeature.Action>{
        .run { send in
            // Realm 객체 생성
            try await analyzeAPI.initAction()
            // 시간 설정
            guard let prevDate = await timeBackground.date else { return }
            if Date().isOverTwoDays(prevDate: prevDate){
                await send(.setStatus(.standBy, isRequiredSetTimer: true))
                return
            }
            let difference = Int(Date().timeIntervalSince(prevDate))
            await timeBackground.set(date: nil)
            let savedValues:PomoValues = await pomoDefaults.getAll() // 저장된 값
            let prevStatus = await timeBackground.timerStatus // 이전 상태
            let pauseStatus = savedValues.status // 이전 상태에서 Pause한 상태
            await send(.setDefaultValues(savedValues)) // 저장된 값에서 타이머 Feature를 가져옴
            //MARK: -- 이전 상태와 저장된 상태를 통해서 메서드를 호출
            switch (prevStatus,pauseStatus){
            case (_,.focus),(_,.breakTime): // 이전 상태가 타이머를 사용하는 상태
                fatalError("이게 왜 돌아가...")
            case (_,.completed),(_,.standBy): break
            case (.pause,.pause): break
            case (.focus,.pause(.focusPause)): // 포커스 타임이지만, 일시적으로 Pause한 상태
                guard let info = savedValues.information else {
                    fatalError("여기에는 정보가 있어야한다.")
                }
                if info.isPomoMode{
                    await pomoTimerFocus(send, value: savedValues, diff: difference)
                }else{
                    await defaultTimerFocus(send, value: savedValues, diff: difference)
                }
            case (.breakTime,.pause(.breakPause)):
                await self.pomoTimerBreak(send, value: savedValues, diff: difference)
            default: print("알 수 없는 상태 \(prevStatus) \(savedValues.status)")
            }
        }
    }
}

//MARK: -- focus 상태일 때 처리
extension TimerFeature{
    fileprivate typealias Sender = Send<TimerFeature.Action>
    // 기본 타이머 집중 상태에서 멈추었다 다시 가져온다.
    fileprivate func defaultTimerFocus(_ send: Send<TimerFeature.Action>,value:PomoValues,diff:Int) async{
        let restTime = value.count - diff
        if restTime > 0{
            await send(.setStatus(.focus, isRequiredSetTimer: false))
            await send(.setTimerRunning(restTime))
        }else{
            await send(.setStatus(.completed))
        }
    }
    // 포모 타이머 집중 상태에서 멈추었다 다시 가져온다.
    fileprivate func pomoTimerFocus(_ send: Sender,value: PomoValues,diff:Int) async{
        guard let info = value.information else {fatalError("여기에는 정보가 있어야한다.")}
        var timeDiff = diff - value.count
        var cycle = value.cycle
        var newValue = value
        if timeDiff <= 0{ // 포커스 상태에서 다른 상태를 바꿀 필요가 없다.
            await send(.setStatus(.focus, isRequiredSetTimer: false))
            await send(.setTimerRunning(value.count - diff))
        }else{ // 포커스 상태에서 다른 상태로 가야한다.
            cycle += 1
            let restCycle = info.cycle - cycle
            // 사이클 시간 -> focus 시간 + breakTime
            let cycleTime = info.timeSeconds + info.breakTime
            if restCycle <= 0{
                // 처리할 사이클이 존재하지 않음... Complete로 넘어간다.
                await send(.setStatus(.completed, isRequiredSetTimer: true))
            }else{ // 아직 처리해야할 사이클이 존재함...
                let availableCycle = min(timeDiff / cycleTime, restCycle)
                cycle += availableCycle
                timeDiff -= availableCycle * cycleTime
                newValue.cycle = cycle
                await send(.setDefaultValues(newValue))
                if cycle == info.cycle{
                    // 처리할 사이클이 존재하지 않음... Complete로 넘어간다.
                    await send(.setStatus(.completed, isRequiredSetTimer: true))
                }else if cycle < info.cycle{ // 처리할 사이클이 남음
                    if timeDiff - info.breakTime < 0{
                        // breakTime을 전부 소화 못함 -> breakTime 남은 시간 할당해야함
                        await send(.setStatus(.breakTime, isRequiredSetTimer: false))
                        await send(.setTimerRunning(info.breakTime - timeDiff))
                    }else{
                        // breakTime을 전부 소화함 -> Focus에 남은 시간을 할당해야함
                        timeDiff -= info.breakTime
                        await send(.setStatus(.focus, isRequiredSetTimer: false))
                        await send(.setTimerRunning(info.timeSeconds - timeDiff))
                    }
                }else{
                    fatalError("cycle이 기존에 목표 cycle보다 크다.")
                }
            }
        }
    }

}
//MARK: -- shortBreak 상태일 때 처리
extension TimerFeature{
    fileprivate func pomoTimerBreak(_ send: Sender,value: PomoValues,diff: Int) async {
        guard let info = value.information else {fatalError("여기에는 정보가 있어야한다.")}
        var timeDiff = diff - value.count
        var cycle = value.cycle
        var newValue = value
        if timeDiff <= 0{
            await send(.setStatus(.breakTime, isRequiredSetTimer: false))
            await send(.setTimerRunning(value.count - diff))
        }else{
            newValue.count = info.timeSeconds
            newValue.status = .pause(.focusPause)
            await pomoTimerFocus(send, value: newValue, diff: timeDiff)
        }
    }
}
