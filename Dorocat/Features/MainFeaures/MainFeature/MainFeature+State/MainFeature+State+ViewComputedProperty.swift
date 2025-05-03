//
//  MainFeature+State_ViewComputedProperty.swift
//  Dorocat
//
//  Created by Greem on 10/26/24.
//

import Foundation

// MARK: -- View에서 사용하는 계산 프로퍼티
extension MainFeature.State {
    private var count: Int {
        timerProgressEntity.count
    }
    
    var cycleNote: String { // 현재 목표가 되는 사이클
        "\(timerProgressEntity.cycle + 1)/\(timerSettingEntity.cycle)"
    }
    
    var timer: String {
        "\(count / 60 < 10 ? "0" : "")\(count / 60):\((count % 60) < 10 ? "0":"")\(count % 60)"
    }
    var progress: Double {
        switch timerProgressEntity.status {
            case .focus: Double(count) / (60 * 60)
            case .breakTime: Double(count) / (60 * 60)
            default: 0.0
        }
    }
    var totalTime: String {
        let cycle = timerSettingEntity.isPomoMode ? timerSettingEntity.cycle : 1
        let rawTimeSeconds = cycle * timerSettingEntity.timeSeconds
        let totalMin = rawTimeSeconds / 60
        return "\(totalMin / 60)h \(totalMin % 60)m"
    }
}
