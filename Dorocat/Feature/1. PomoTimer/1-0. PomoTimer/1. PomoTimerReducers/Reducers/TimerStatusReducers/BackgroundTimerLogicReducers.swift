//
//  BackgroundLogicReducers.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
import ComposableArchitecture

extension PomoTimerFeature{
    func awakeTimer(_ send: Send<PomoTimerFeature.Action>) async {
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
        let savedValues:DoroStateEntity = await doroStateDefaults.getDoroStateEntity() // 디스크에 저장된 값
        await send(.setDoroStateEntity(savedValues)) // 디스크에 저장된 값을 State에 보냄
        let pauseStatus = await timeBackground.timerStatus  // 이전 상태에서 Sleep한 상태
        let prevStatus = savedValues.progressEntity.status // 이전 상태
        //MARK: -- 이전 상태와 저장된 상태를 통해서 메서드를 호출
        print("**Timer Status",prevStatus,pauseStatus,difference )
        switch prevStatus {
        case .standBy,.pause,.completed,.breakStandBy,.focusStandBy: break
        case .focus:
            switch pauseStatus{
            case .focusSleep:
                if savedValues.settingEntity.isPomoMode{
                    await pomoTimerFocus(send, doroEntity: savedValues, diff: difference)
                }else{
                    await defaultTimerFocus(send, doroEntity: savedValues, diff: difference)
                }
            default: break
            }
        case .breakTime:
            switch pauseStatus{
            case .breakSleep:
                await self.pomoTimerBreak(send, doroEntity: savedValues, diff: difference)
            default: break
            }
        case .focusSleep:
            if savedValues.settingEntity.isPomoMode{
                await pomoTimerFocus(send, doroEntity: savedValues, diff: difference)
            }else{
                await defaultTimerFocus(send, doroEntity: savedValues, diff: difference)
            }
        case .breakSleep:
            await self.pomoTimerBreak(send, doroEntity: savedValues, diff: difference)
        }
    }
}

//MARK: -- focus 상태일 때 처리
extension PomoTimerFeature{
    fileprivate typealias Sender = Send<PomoTimerFeature.Action>
    // 1. 기본 타이머 집중 상태에서 멈추었다 다시 가져온다.
    fileprivate func defaultTimerFocus(_ send: Send<PomoTimerFeature.Action>,
                                       doroEntity:DoroStateEntity,
                                       diff:Int) async{
        let restTime = doroEntity.progressEntity.count - diff
        if restTime > 0{
            await send(.setStatus(.focus, count:restTime))
        }else{
            await send(.setStatus(.completed))
        }
    }
    // 2. 포모 타이머 집중 상태에서 멈추었다 다시 가져온다.
    fileprivate func pomoTimerFocus(_ send: Sender,doroEntity: DoroStateEntity,diff: Int) async {
        let restTime = doroEntity.progressEntity.count - diff
        if restTime > 0{
            await send(.setStatus(.focus,count: restTime))
        }else{
            let cycle = doroEntity.progressEntity.cycle + 1
            let restCycle = doroEntity.settingEntity.cycle - cycle
            var newValue = doroEntity
            newValue.progressEntity.cycle = cycle
            newValue.progressEntity.count = 0
            await send(.setDoroStateEntity(newValue))
            if restCycle <= 0{
                await send(.setStatus(.completed))
            }else{
                await send(.setStatus(.breakStandBy))
            }
        }
    }
    //MARK: -- breakTime 상태일 때 처리
    fileprivate func pomoTimerBreak(_ send: Sender,doroEntity: DoroStateEntity,diff: Int) async{
        let restTime = doroEntity.progressEntity.count - diff
//        var newValue = doroEntity
        if restTime > 0{
            await send(.setStatus(.breakTime, count:restTime))
        }else{
            await send(.setStatus(.focusStandBy))
        }
    }
}

