//
//  BackgroundLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
import ComposableArchitecture

extension MainFeature{
    func awakeTimer(_ send: Send<MainFeature.Action>) async {
        // 시간 설정, 저장해둔 타이머 시간 정보가 없으면 저장한 Status 값 그대로 보존한다.
        guard let prevDate = await timeBackground.date else {
            print("이게 문제")
            return
        }
        if Date().isOverTwoDays(prevDate: prevDate){
            await send(.setStatus(.standBy))
            return
        }
        await timeBackground.set(date: Date())
        let difference = Int(Date().timeIntervalSince(prevDate))
        let savedValues:PomoValues = await pomoDefaults.getAll() // 디스크에 저장된 값
        await send(.setDefaultValues(savedValues)) // 디스크에 저장된 값을 State에 보냄
        let pauseStatus = await timeBackground.timerStatus  // 이전 상태에서 Sleep한 상태
        let prevStatus = savedValues.status // 이전 상태
        //MARK: -- 이전 상태와 저장된 상태를 통해서 메서드를 호출
        print("**Timer Status",prevStatus,pauseStatus,difference )
        switch prevStatus {
        case .standBy,.pause,.completed,.breakStandBy,.focusStandBy: break
        case .focus:
            switch pauseStatus{
            case .sleep(.focusSleep):
                guard let info = savedValues.information else { fatalError("여기에는 정보가 있어야한다.") }
                if info.isPomoMode{
                    await pomoTimerFocus(send, value: savedValues, diff: difference)
                }else{
                    await defaultTimerFocus(send, value: savedValues, diff: difference)
                }
            default: break
            }
        case .breakTime:
            switch pauseStatus{
            case .sleep(.breakSleep):
                await self.pomoTimerBreak(send, value: savedValues, diff: difference)
            default: break
            }
        case .sleep(.focusSleep):
            guard let info = savedValues.information else { fatalError("여기에는 정보가 있어야한다.") }
            if info.isPomoMode{
                await pomoTimerFocus(send, value: savedValues, diff: difference)
            }else{
                await defaultTimerFocus(send, value: savedValues, diff: difference)
            }
        case .sleep(.breakSleep):
            await self.pomoTimerBreak(send, value: savedValues, diff: difference)
        }
    }
}

//MARK: -- focus 상태일 때 처리
extension MainFeature{
    fileprivate typealias Sender = Send<MainFeature.Action>
    // 1. 기본 타이머 집중 상태에서 멈추었다 다시 가져온다.
    fileprivate func defaultTimerFocus(_ send: Send<MainFeature.Action>,value:PomoValues,diff:Int) async{
        let restTime = value.count - diff
        if restTime > 0{
            await send(.setStatus(.focus, count:restTime))
        }else{
            await send(.setStatus(.completed))
        }
    }
    // 2. 포모 타이머 집중 상태에서 멈추었다 다시 가져온다.
    fileprivate func pomoTimerFocus(_ send: Sender,value: PomoValues,diff: Int) async {
        guard let info = value.information else {fatalError("여기에는 정보가 있어야한다.")}
        let restTime = value.count - diff
        if restTime > 0{
            await send(.setStatus(.focus,count: restTime))
        }else{
            let cycle = value.cycle + 1
            let restCycle = info.cycle - cycle
            var newValue = value
            newValue.cycle = cycle
            newValue.count = 0
            await send(.setDefaultValues(newValue))
            if restCycle <= 0{
                await send(.setStatus(.completed))
            }else{
                await send(.setStatus(.breakStandBy))
            }
        }
    }
    //MARK: -- breakTime 상태일 때 처리
    fileprivate func pomoTimerBreak(_ send: Sender,value: PomoValues,diff: Int) async{
        guard let info = value.information else {fatalError("여기에는 정보가 있어야한다.")}
        let restTime = value.count - diff
        var newValue = value
        if restTime > 0{
            await send(.setStatus(.breakTime, count:restTime))
        }else{
            await send(.setStatus(.focusStandBy))
        }
    }
}

