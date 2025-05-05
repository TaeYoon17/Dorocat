//
//  HapticRepository.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation
import UIKit

/// 개별 액터 작업
actor HapticRepositoryImpl: HapticDependency {
    
    private let defaultsService = UserDefaultsService()
    
    /// 메인 엑터가 보장됨
    @MainActor
    private lazy var hapticService = HapticService()
    
    var enable: Bool {
        get async {
            let res = defaultsService.load(type: Bool.self, key: .hapticEnabled)
            switch res {
            case .success(let success): return success
            case .failure: return false
            }
        }
    }
    
    func setEnable(_ isEnable: Bool) async {
        defaultsService.save(value: isEnable, key: .hapticEnabled)
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) async {
        guard await enable else { return }
        await hapticService.notificationOccur(type: type)
    }
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) async {
        guard await enable else { return }
        await hapticService.impact(style: style)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) async {
        guard await enable else { return }
        await hapticService.impact(style: style, intensity: intensity)
    }
}
