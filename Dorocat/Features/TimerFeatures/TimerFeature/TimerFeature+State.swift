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
        var timerSessionType = "Focus"
        var selectedSession: SessionItem = .init(name: "Focus")
        var guideInformation = Guides()
        // 앱에서 running일 때 사용할 정보들
        var count = 0
        var cycle = 0
        var isAppLaunched = false
        var progress:Double{
            switch timerStatus{
            case .focus: Double(count) / (60 * 60)
            case .breakTime: Double(count) / (60 * 60)
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
            let cycle = timerInformation.isPomoMode ? timerInformation.cycle : 1
            let rawTimeSeconds = cycle * timerInformation.timeSeconds
            let totalMin = rawTimeSeconds / 60
            return "\(totalMin / 60)h \(totalMin % 60)m"
        }
        var startDate = Date()
        @Presents var timerSetting: TimerSettingFeature.State?
        @Presents var timerSession: TimerSessionFeature.State?
        var appState = DorocatFeature.AppStateType.active
    }
}
