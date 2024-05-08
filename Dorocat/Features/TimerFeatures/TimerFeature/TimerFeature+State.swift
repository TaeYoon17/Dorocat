//
//  TimerFeature+State.swift
//  Dorocat
//
//  Created by Developer on 3/28/24.
//

import Foundation
import ComposableArchitecture
extension TimerFeature{
    @ObservableState struct State: Equatable{
        var timerStatus = TimerFeatureStatus.standBy
        var timerInformation = TimerInformation() // 앱에서 설정한 정보...
        var guideInformation = Guides()
        // 앱에서 running일 때 사용할 정보들
        var count = 0
        var cycle = 0
        var isAppLaunched = false
        var progress:Double{
            switch timerStatus{
            case .focus: Double(count) / (60 * 60)
//                Double(timerInformation.timeSeconds)
            case .breakTime: Double(count) / (60 * 60)
//                Double(timerInformation.breakTime)
            default: 0.0
            }
        }
        var timer:String {
            "\(count / 60 < 10 ? "0" : "")\(count / 60):\((count % 60) < 10 ? "0":"")\(count % 60)"
        }
        var cycleNote:String{
            "\(cycle) / \(timerInformation.cycle)"
        }
        var totalTime: String{
            let cycle = timerInformation.isPomoMode ? 1 : timerInformation.cycle
            let rawTimeSeconds = cycle * timerInformation.timeSeconds
            let hour = rawTimeSeconds / 3600
            let min = (rawTimeSeconds - hour * 3600) / 60
            return "\(hour)h \(min)m"
        }
        var startDate = Date()
        @Presents var timerSetting: TimerSettingFeature.State?
        var appState = DorocatFeature.AppStateType.active
    }
}
