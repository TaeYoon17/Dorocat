import Foundation

//MARK: -- Legacy... CycleCompleted 상태가 없이 바로 넘어가는 경우를 구현
/*
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
*/
